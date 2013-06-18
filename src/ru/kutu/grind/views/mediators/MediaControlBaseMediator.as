package ru.kutu.grind.views.mediators {

	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	import ru.kutu.grind.events.MediaElementChangeEvent;

	public class MediaControlBaseMediator extends Mediator {

		[Inject] public var player:MediaPlayer;
		
		private var needDetectStreamType:Boolean = true;
		
		private var _media:MediaElement;
		private var _requiredTraitsAvailable:Boolean;
		private var _streamType:String;

		override public function initialize():void {
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			addContextListener(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGED, onMediaChanged, MediaElementChangeEvent);
			onMediaChanged();
		}

		public function get media():MediaElement {
			return _media;
		}
		
		public function get streamType():String {
			return _streamType;
		}
		
		protected function get requiredTraits():Vector.<String> {
			return null;
		}

		protected function processMediaElementChange(oldMediaElement:MediaElement):void {
		}

		protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
		}

		protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
		}

		protected function processRequiredTraitsAvailable(element:MediaElement):void {
		}

		protected function processRequiredTraitsUnavailable(element:MediaElement):void {
		}
		
		protected function onStreamTypeChange(streamType:String):void {
		}
		
		private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			// check streamType change
			if (needDetectStreamType) {
				switch (event.state) {
					case MediaPlayerState.READY:
					case MediaPlayerState.PLAYING:
					case MediaPlayerState.BUFFERING:
					case MediaPlayerState.PAUSED:
						var streamType:String = MediaElementUtils.getStreamType(_media);
						if (streamType != _streamType) {
							_streamType = streamType;
							onStreamTypeChange(streamType);
						}
						needDetectStreamType = false;
						break;
				}
			}
		}
		
		private function onMediaChanged(event:MediaElementChangeEvent = null):void {
			var value:MediaElement = player.media;
			if (_media != value) {
				var oldValue:MediaElement = _media;
				_media = null;

				if (oldValue) {
					oldValue.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					oldValue.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
					onMediaElementTraitsChange(null);
				}

				_media = value;

				if (_media) {
					_media.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					_media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				}

				processMediaElementChange(oldValue);
				onMediaElementTraitsChange(null);
				
				needDetectStreamType = true;
			}
		}

		private function onMediaElementTraitsChange(event:MediaElementEvent = null):void {
			var element:MediaElement = event
				? event.target as MediaElement
				: _media;

			var priorRequiredTraitsAvailable:Boolean = _requiredTraitsAvailable;

			if (element) {
				_requiredTraitsAvailable = true;
				for each (var type:String in requiredTraits) {
					if (element.hasTrait(type) == false || (event != null && event.type == MediaElementEvent.TRAIT_REMOVE && event.traitType == type)) {
						_requiredTraitsAvailable = false;
						break;
					}
				}
			} else {
				_requiredTraitsAvailable = false;
			}

			if	(	event == null // always invoke handlers, if change is not event driven.
				||	_requiredTraitsAvailable != priorRequiredTraitsAvailable
			) {
				_requiredTraitsAvailable
				? processRequiredTraitsAvailable(element)
					: processRequiredTraitsUnavailable(element);
			}

			if (event) {
				event.type == MediaElementEvent.TRAIT_ADD
					? onMediaElementTraitAdd(event)
					: onMediaElementTraitRemove(event);
			}
		}

	}

}
