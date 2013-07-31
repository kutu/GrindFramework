package ru.kutu.grind.config {

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DVREvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.NetStreamCodes;
	
	import robotlegs.bender.extensions.localEventMap.api.IEventMap;
	
	import ru.kutu.grind.events.LoadMediaEvent;
	import ru.kutu.grind.events.MediaElementChangeEvent;

	public class JavaScriptBridgeBase {

		[Inject] public var eventMap:IEventMap;
		[Inject] public var eventDispatcher:IEventDispatcher;
		[Inject] public var player:MediaPlayer;
		[Inject] public var playerConfiguration:PlayerConfiguration;

		protected var media:MediaElement;
		protected var eventTypeListeners:Object = {};
		protected var eventMaps:Dictionary;
		protected var javascriptCallbackFunction:String;
		
		protected var declaredByWhiteList:Array = [
			"org.osmf.media::MediaPlayer"
			, "ru.kutu.grind.media::GrindMediaPlayerBase"
		];
		protected var typeBlackList:Array = [
			"org.osmf.media::MediaElement"
			, "flash.display::DisplayObject"
			, "ru.kutu.grind.config::PlayerConfiguration"
			, "flash.events::IEventDispatcher"
		];
		protected var methodBlackList:Array = [
			"init"
			, "play"
			, "stop"
		];

		[PostConstruct]
		public function init():void {
			javascriptCallbackFunction = playerConfiguration.javascriptCallbackFunction;
			if (ExternalInterface.available) {
				try {
					createJSBridge();
				} catch(_:Error) {
					trace("allowScriptAccess is set to false. JavaScript API is not enabled.");
				}
			}
		}

		public function call(args:Array, async:Boolean = true):void {
			if (async) {
				var asyncTimer:Timer = new Timer(10, 1);
				asyncTimer.addEventListener(TimerEvent.TIMER,
					function(event:Event):void {
						asyncTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						ExternalInterface.call.apply(ExternalInterface, args);
					}
				);
				asyncTimer.start();
			} else {
				ExternalInterface.call.apply(ExternalInterface, args);
			}
		}

		protected function createJSBridge():void {
			// Add callback methods
			ExternalInterface.addCallback("addEventListener", addEventListener);
			ExternalInterface.addCallback("addEventListeners", addEventListeners);

			var typeXml:XML = describeType(getDefinitionByName(getQualifiedClassName(player)));

			// Walk all the variables...
			for each (var variable:XML in typeXml.factory.variable) {
				if (typeBlackList.indexOf(variable.@type.toString()) < 0) {
					exposeProperty(player, variable.@name.toString(), false);
				}
			}

			// ...and all the accessors...
			for each (var accessor:XML in typeXml.factory.accessor) {
				if (declaredByWhiteList.indexOf(accessor.@declaredBy.toString()) >= 0) {
					if (typeBlackList.indexOf(accessor.@type.toString()) < 0) {
						exposeProperty(player, accessor.@name.toString(), accessor.@access == "readonly");
					}
				}
			}

			// ...and all the methods.
			for each (var method:XML in typeXml.factory.method) {
				if (declaredByWhiteList.indexOf(method.@declaredBy.toString()) >= 0) {
					var methodName:String = method.@name.toString();
					if (typeBlackList.indexOf(method.@returnType.toString()) < 0) {
						var ok:Boolean = true;
						for each(var param:XML in method.parameter) {
							if (!param.@optional && typeBlackList.indexOf(param.@type.toString()) >= 0) {
								ok = false;
								break;
							}
						}
						if (ok) {
							if (methodBlackList.indexOf(methodName) < 0) {
								ExternalInterface.addCallback(methodName, player[methodName]);
							}
						}
					}
				}
			}

			initializeEventMap();

			// We are ready, notify the javascript client.

			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			player.addEventListener(AudioEvent.MUTED_CHANGE, onVolumeChange);
			player.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			player.addEventListener(TimeEvent.COMPLETE, onComplete);
			player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			player.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
			player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);

			ExternalInterface.addCallback("play2", player.play);
			ExternalInterface.addCallback("stop2", player.stop);

			ExternalInterface.addCallback("setResourceMetadata", setResourceMetadata);
			ExternalInterface.addCallback("setMediaResourceURL", setMediaResourceURL);
			ExternalInterface.addCallback("load", load);

			call([javascriptCallbackFunction, ExternalInterface.objectID, "onJavaScriptBridgeCreated"], false);
			
			eventMap.mapListener(eventDispatcher, MediaElementChangeEvent.MEDIA_ELEMENT_CHANGED, onMediaElementChanged, MediaElementChangeEvent);
		}

		protected function setResourceMetadata(name:String = null, value:String = null):void {
			if (name == null) return;
			if (value == null) {
				delete playerConfiguration.metadata[name];
			} else {
				playerConfiguration.metadata[name] = value;
			}
		}

		protected function setMediaResourceURL(url:String):void {
			if (url == null) return;
			playerConfiguration.src = url;
			load();
		}

		protected function load():void {
			eventDispatcher.dispatchEvent(new LoadMediaEvent(LoadMediaEvent.LOAD_MEDIA));
		}

		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			switch (event.state) {
				case MediaPlayerState.READY:
					call([javascriptCallbackFunction, ExternalInterface.objectID, "ready"]);
					break;
				case MediaPlayerState.LOADING:
					call([javascriptCallbackFunction, ExternalInterface.objectID, "loading"]);
					break;
				case MediaPlayerState.PLAYING:
					call([javascriptCallbackFunction, ExternalInterface.objectID, "playing"]);
					break;
				case MediaPlayerState.PAUSED:
					call([javascriptCallbackFunction, ExternalInterface.objectID, "paused"]);
					break;
				case MediaPlayerState.BUFFERING:
					call([javascriptCallbackFunction, ExternalInterface.objectID, "buffering"]);
					break;
			}
		}

		protected function onMediaElementChanged(event:MediaElementChangeEvent):void {
			media = player.media;
		}

		protected function onMediaSizeChange(event:DisplayObjectEvent):void {
			call([javascriptCallbackFunction, ExternalInterface.objectID, "mediaSize",
				{videoWidth: player.mediaWidth, videoHeight: player.mediaHeight}]);
		}

		protected function onSeekingChange(event:SeekEvent):void {
			if (event.seeking) {
				call([javascriptCallbackFunction, ExternalInterface.objectID, "seeking"]);
			} else {
				call([javascriptCallbackFunction, ExternalInterface.objectID, "seeked"]);
			}
		}

		protected function onVolumeChange(event:AudioEvent):void {
			call([javascriptCallbackFunction, ExternalInterface.objectID, "volumeChange", {muted: player.muted, volume: player.volume}]);
		}

		protected function onDurationChange(event:TimeEvent):void {
			call([javascriptCallbackFunction, ExternalInterface.objectID, "durationChange", {duration:player.duration}]);
		}

		protected function onCurrentTimeChange(event:TimeEvent):void {
			call([javascriptCallbackFunction, ExternalInterface.objectID, "timeChange", {duration:player.duration, currentTime:player.currentTime}]);
		}

		protected function onBytesLoadedChange(event:LoadEvent):void {
			var end:Number = player.duration * player.bytesLoaded / player.bytesTotal;
			var buffered:Object = {
				length:1,
				_start: [0],
				_end: [end]
			};
			call([javascriptCallbackFunction, ExternalInterface.objectID, "progress", {buffered:buffered}]);
		}

		protected function onComplete(event:TimeEvent):void {
			call([javascriptCallbackFunction, ExternalInterface.objectID, "complete"]);
		}

		protected function initializeEventMap():void {
			eventMaps = new Dictionary();
			// Trait Events
			eventMaps[TimeEvent.DURATION_CHANGE]					= function(event:TimeEvent):Array { return [event.time] };
			eventMaps[TimeEvent.COMPLETE]							= function(event:TimeEvent):Array { return [event.time] };
			eventMaps[PlayEvent.PLAY_STATE_CHANGE]					= function(event:PlayEvent):Array { return [event.playState] };
			eventMaps[PlayEvent.CAN_PAUSE_CHANGE]					= function(event:PlayEvent):Array { return [event.canPause] };
			eventMaps[AudioEvent.VOLUME_CHANGE]						= function(event:AudioEvent):Array { return [event.volume] };
			eventMaps[AudioEvent.MUTED_CHANGE]						= function(event:AudioEvent):Array { return [event.muted] };
			eventMaps[AudioEvent.PAN_CHANGE]						= function(event:AudioEvent):Array { return [event.pan] };
			eventMaps[AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE]	= function(event:AlternativeAudioEvent):Array { return [event.switching] };
			eventMaps[AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE]	= function(event:AlternativeAudioEvent):Array { return [] };
			eventMaps[SeekEvent.SEEKING_CHANGE]						= function(event:SeekEvent):Array { return [event.time] };
			eventMaps[DynamicStreamEvent.SWITCHING_CHANGE] 			= function(event:DynamicStreamEvent):Array { return [event.switching] };
			eventMaps[DynamicStreamEvent.AUTO_SWITCH_CHANGE] 		= function(event:DynamicStreamEvent):Array { return [event.autoSwitch] };
			eventMaps[DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE] = function(event:DynamicStreamEvent):Array { return [] };
			eventMaps[DisplayObjectEvent.DISPLAY_OBJECT_CHANGE]		= function(event:DisplayObjectEvent):Array { return [] };
			eventMaps[DisplayObjectEvent.MEDIA_SIZE_CHANGE] 		= function(event:DisplayObjectEvent):Array { return [event.newWidth, event.newHeight] };
			eventMaps[LoadEvent.LOAD_STATE_CHANGE]					= function(event:LoadEvent):Array { return [event.loadState] };
			eventMaps[LoadEvent.BYTES_LOADED_CHANGE]				= function(event:LoadEvent):Array { return [event.bytes] };
			eventMaps[LoadEvent.BYTES_TOTAL_CHANGE]					= function(event:LoadEvent):Array { return [event.bytes] };
			eventMaps[BufferEvent.BUFFERING_CHANGE]					= function(event:BufferEvent):Array { return [event.buffering] };
			eventMaps[BufferEvent.BUFFER_TIME_CHANGE]				= function(event:BufferEvent):Array { return [event.bufferTime] };
			eventMaps[DRMEvent.DRM_STATE_CHANGE]					= function(event:DRMEvent):Array { return [event.drmState] };
			eventMaps[DVREvent.IS_RECORDING_CHANGE]					= function(event:DVREvent):Array { return [] };

			// MediaPlayerCapabilityChangeEvent(s)
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE]				= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE]		= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE]				= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE]		= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };
			eventMaps[MediaPlayerCapabilityChangeEvent.HAS_ALTERNATIVE_AUDIO_CHANGE]	= function(event:MediaPlayerCapabilityChangeEvent):Array { return [event.enabled] };

			// MediaPlayer events
			eventMaps[MediaErrorEvent.MEDIA_ERROR]		= function(event:MediaErrorEvent):Array { return [event.error.errorID, event.error.message, event.error.detail] };
			eventMaps[TimeEvent.CURRENT_TIME_CHANGE]	= function(event:TimeEvent):Array { return [event.time] };
			eventMaps[MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE]	= function(event:MediaPlayerStateChangeEvent):Array { return [event.state] };
			eventMaps[QoSInfoEvent.QOS_UPDATE]			= function(event:QoSInfoEvent):Array { return [event.qosInfo] };
			eventMaps[NetStreamCodes.ON_META_DATA]		= function(event:MetadataEvent):Array { return [event.value] };
		}

		protected function addEventListener(type:String, callback:String):void {
			if (eventMaps.hasOwnProperty(type)) {
				player.addEventListener(type,
					function(event:Event):void {
						var args:Array = eventMaps[event.type](event);
						args.unshift(callback);
						args.push(ExternalInterface.objectID);
						call(args);
					}
				);
			}
		}

		protected function addEventListeners(typeListenerMapping:Object):void {
			for (var type:String in typeListenerMapping) {
				addEventListener(type, typeListenerMapping[type]);
			}
		}

		protected function exposeProperty(instance:Object, propertyName:String, readOnly:Boolean):void {
			var capitalizedPropertyName:String = propertyName.charAt(0).toUpperCase() + propertyName.substring(1);
			var getPropertyName:String = "get" + capitalizedPropertyName;
			ExternalInterface.addCallback(getPropertyName, function():* { return instance[propertyName] });

			if (!readOnly) {
				var setPropertyName:String = "set" + capitalizedPropertyName
				ExternalInterface.addCallback(setPropertyName, function(value:*):void { instance[propertyName] = value });
			}
		}

	}

}
