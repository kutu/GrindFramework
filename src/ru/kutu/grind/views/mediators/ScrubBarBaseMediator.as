package ru.kutu.grind.views.mediators {
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.StreamType;
	import org.osmf.traits.MediaTraitType;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	
	import ru.kutu.grind.events.AutoHideEvent;
	import ru.kutu.grind.events.ScrubBarEvent;
	import ru.kutu.grind.views.api.IScrubBar;
	
	public class ScrubBarBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var mediatorMap:IMediatorMap;
		[Inject] public var view:IScrubBar;
		
		protected var isStartPlaying:Boolean;
		protected var sliderChanging:Boolean;
		protected var totalBytes:Number;
		protected var loadedBytes:Number;
		
		private var _requiredTraits:Vector.<String> = new <String>[MediaTraitType.TIME, MediaTraitType.SEEK];
		
		override public function initialize():void {
			super.initialize();
			updateEnabled();
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChage);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			player.addEventListener(TimeEvent.COMPLETE, onComplete);
			player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekChange);
			player.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
			player.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
			addViewListener(ScrubBarEvent.SLIDER_CHANGE_START, onSliderChangeStart, ScrubBarEvent);
			addViewListener(ScrubBarEvent.SLIDER_CHANGE_END, onSliderChangeEnd, ScrubBarEvent);
			addViewListener(ScrubBarEvent.SLIDER_CHANGE, onSliderChange, ScrubBarEvent);
			mediatorMap.mediate(view.tip);
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
			super.processMediaElementChange(oldMediaElement);
			totalBytes = loadedBytes = NaN;
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			if (isStartPlaying) {
				switch (event.state) {
					case MediaPlayerState.UNINITIALIZED:
					case MediaPlayerState.LOADING:
					case MediaPlayerState.READY:
					case MediaPlayerState.PLAYBACK_ERROR:
						isStartPlaying = false;
						break;
				}
				return;
			}
			isStartPlaying = event.state == MediaPlayerState.PLAYING;
			updateEnabled();
		}
		
		override protected function get requiredTraits():Vector.<String> {
			return _requiredTraits;
		}
		
		override protected function onStreamTypeChange(streamType:String):void {
			updateEnabled();
		}
		
		protected function onCurrentTimeChage(event:TimeEvent):void {
			if (sliderChanging) return;
			view.value = event.time;
		}
		
		protected function onDurationChange(event:TimeEvent):void {
			if (sliderChanging) return;
			view.maximum = event.time;
		}
		
		protected function onComplete(event:TimeEvent):void {
			if (sliderChanging) return;
			view.value = view.maximum;
		}
		
		protected function onSeekChange(event:SeekEvent):void {
			if (sliderChanging) return;
			view.value = event.time;
		}

		protected function onBytesTotalChange(event:LoadEvent):void {
			totalBytes = event.bytes;
			if (isNaN(totalBytes) || totalBytes <= 0 || isNaN(loadedBytes)) return;
			view.percentLoaded = loadedBytes / totalBytes;
		}
		protected function onBytesLoadedChange(event:LoadEvent):void {
			loadedBytes = event.bytes;
			if (isNaN(totalBytes) || totalBytes <= 0 || isNaN(loadedBytes)) return;
			view.percentLoaded = event.bytes / totalBytes;
		}
		
		protected function onSliderChangeStart(event:ScrubBarEvent):void {
			sliderChanging = true;
			dispatch(new AutoHideEvent(AutoHideEvent.WAIT_ME, "scrubBar"));
		}
		protected function onSliderChangeEnd(event:ScrubBarEvent):void {
			sliderChanging = false;
			onSliderChange();
			dispatch(new AutoHideEvent(AutoHideEvent.FORGET_ME, "scrubBar"));
		}
		protected function onSliderChange(event:ScrubBarEvent = null):void {
			if (!isStartPlaying) return;
			if (sliderChanging) return;
			if (player.canSeek) {
				var seekTo:Number;
				if (!isNaN(player.duration) && player.duration > 0) {
					if (streamType == StreamType.DVR) {
						seekTo = Math.min(view.value, player.duration - 2.0 * player.bufferTime);
					} else {
						seekTo = Math.min(view.value, player.duration - 1.0);
					}
				}
				if (!isNaN(seekTo) && player.canSeekTo(seekTo)) {
					player.seek(seekTo);
				}
			}
		}
		
		protected function updateEnabled():void {
			view.enabled = isStartPlaying;
			view.visible = streamType != StreamType.LIVE;
		}
		
	}
	
}
