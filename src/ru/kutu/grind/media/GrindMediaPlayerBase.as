package ru.kutu.grind.media {

	import flash.errors.IllegalOperationError;
	import flash.events.IEventDispatcher;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
	import ru.kutu.grind.config.PlayerConfiguration;
	import ru.kutu.grind.events.MediaElementChangeEvent;

	public class GrindMediaPlayerBase extends MediaPlayer {
		
		[Inject] public var eventDispatcher:IEventDispatcher;
		[Inject] public var configuration:PlayerConfiguration;
		
		public function GrindMediaPlayerBase(media:MediaElement=null) {
			super(media);
			addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
		}
		
		override public function set media(value:MediaElement):void {
			if (!media && !value) return;
			
			var traitType:String;
			
			if (media) {
				media.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				media.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				for each (traitType in media.traitTypes) {
					updateTraitListenersBase(traitType, false);
				}
			}
			
			super.media = value;
			
			if (media) {
				media.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				for each (traitType  in media.traitTypes) {
					updateTraitListenersBase(traitType, true);
				}
				if (media.metadata && !media.metadata.getValue("org.osmf.player.metadata.MediaMetadata")) {
					media.metadata.addValue("org.osmf.player.metadata.MediaMetadata", {resourceMetadata:{}});
				}
			}
			
			eventDispatcher.dispatchEvent(new MediaElementChangeEvent(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGED));
		}
		
		public function get streamType():String {
			return media ? MediaElementUtils.getStreamType(media) : null;
		}
		
		public function get scaleMode():String {
			if (!media) return null;
			var l:LayoutMetadata = media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
			if (l) {
				return l.scaleMode;
			}
			return null;
		}
		
		public function set scaleMode(value:String):void {
			const scaleModes:Vector.<String> = new <String>[
				ScaleMode.LETTERBOX,
				ScaleMode.ZOOM,
				ScaleMode.STRETCH,
				ScaleMode.NONE
			];
			if (scaleModes.indexOf(value) == -1) return;
			var l:LayoutMetadata = media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
			if (!l) {
				l = new LayoutMetadata();
				media.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, l);
			}
			configuration.scaleMode = value;
			l.scaleMode = value;
		}
		
		public function getDynamicStreamItemAt(index:uint):DynamicStreamingItem {
			if (isDynamicStream) {
				var dyn:DynamicStreamingResource = MediaElementUtils.getResourceFromParentOfType(media, DynamicStreamingResource) as DynamicStreamingResource;
				if (dyn && dyn.streamItems.length > index) {
					return dyn.streamItems[index];
				}
			}
			return null;
		}
		
		protected function onMediaSizeChange(event:DisplayObjectEvent):void {
			var lightweightVideoElement:LightweightVideoElement = MediaElementUtils.getMediaElementParentOfType(media, LightweightVideoElement) as LightweightVideoElement;
			if (lightweightVideoElement) {
				lightweightVideoElement.smoothing = true;
			}
		}
		
		protected function onTraitAdd(event:MediaElementEvent):void {
			updateTraitListenersBase(event.traitType, true);
		}
		
		protected function onTraitRemove(event:MediaElementEvent):void {
			updateTraitListenersBase(event.traitType, false);
		}
		
		protected function updateTraitListenersBase(traitType:String, add:Boolean, skipIfInErrorState:Boolean=true):void {
			// We circumvent this process if we're in an error state (and told
			// to skip this process if we're in an error state), under the
			/// assumption that we've already updated the trait listeners to
			// "hide" the traits as a result of entering the error state.  The
			// one exception to this is the LoadTrait, which is not hidden as
			// the result of a playback error.
			if (	state == MediaPlayerState.PLAYBACK_ERROR
				&& skipIfInErrorState
				&&	traitType != MediaTraitType.LOAD
			) {
				return;
			}
			
			// The default values on each trait property here are checked, events
			// are dispatched if the trait's value is different from the default
			// MediaPlayer's values.  Default values are listed in the ASDocs for
			// the various properties.
			
			// For added traits, the capability is updated (and change event dispatched first).
			if (add) {
				updateCapabilityForTrait(traitType, add);
			}
			
			updateTraitListeners(traitType, add);
			
			// For removed traits, the capability is updated (and change event dispatched) last.
			if (add == false) {
				updateCapabilityForTrait(traitType, false);
			}
		}
		
		protected function updateTraitListeners(traitType:String, add:Boolean):void {
			switch (traitType) {
				case MediaTraitType.LOAD:
					var loadTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
					if (loadTrait && loadTrait.netStream) {
						if (add) {
							loadTrait.netStream.addEventListener(QoSInfoEvent.QOS_UPDATE, dispatchEvent);
							NetClient(loadTrait.netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onNetStreamMetadata);
						} else {
							loadTrait.netStream.removeEventListener(QoSInfoEvent.QOS_UPDATE, dispatchEvent);
							NetClient(loadTrait.netStream.client).removeHandler(NetStreamCodes.ON_META_DATA, onNetStreamMetadata);
						}
					}
					break;
			}
		}
		
		protected function updateCapabilityForTrait(traitType:String, capabilityAdd:Boolean):void {
		}
		
		protected function getTraitOrThrow(traitType:String):MediaTraitBase {
			if (!media || !media.hasTrait(traitType)) {
				var error:String = OSMFStrings.getString(OSMFStrings.CAPABILITY_NOT_SUPPORTED);
				var traitName:String = traitType.replace("[class ", "");
				traitName = traitName.replace("]", "").toLowerCase();	
				
				error = error.replace('*trait*', traitName);
				
				throw new IllegalOperationError(error);
			}
			return media.getTrait(traitType);
		}
		
		protected function onNetStreamMetadata(metadata:Object):void {
			var data:Object = {};
			for (var k:String in metadata) {
				data[k] = metadata[k];
			}
			dispatchEvent(new MetadataEvent(NetStreamCodes.ON_META_DATA, false, false, null, data));
		}
		
	}

}
