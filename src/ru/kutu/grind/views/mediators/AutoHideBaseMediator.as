package ru.kutu.grind.views.mediators {
	
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.PlayState;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IInjector;
	
	import ru.kutu.grind.config.PlayerConfiguration;
	import ru.kutu.grind.events.AutoHideEvent;
	
	public class AutoHideBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var injector:IInjector;
		[Inject] public var contextView:ContextView;
		
		protected var autoHide:Boolean;
		protected var autoHideTimer:Timer;
		
		protected var isReady:Boolean;
		protected var isPlaying:Boolean;
		protected var isMouseLeave:Boolean;
		protected var isMouseMove:Boolean;
		protected var isFullScreen:Boolean;
		protected var isAutoHideComplete:Boolean;
		protected var hasWaitTarget:Boolean;
		protected var isAdvertisement:Boolean;
		
		protected var waitTargets:Dictionary = new Dictionary(true);
		
		protected var _visible:Boolean;
		
		override public function initialize():void {
			super.initialize();
			
			var configuration:PlayerConfiguration = injector.getInstance(PlayerConfiguration);
			
			autoHide = configuration.controlBarAutoHide;
			
			if (configuration.controlBarAutoHideTimeout > 0) {
				autoHideTimer = new Timer(configuration.controlBarAutoHideTimeout * 1000, 1);
				autoHideTimer.addEventListener(TimerEvent.TIMER, onAutoHideTimer);
			}
			
			contextView.view.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			contextView.view.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseMove);
			contextView.view.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseMove);
			contextView.view.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			contextView.view.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			player.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			addContextListener(AutoHideEvent.REPEAT_PLEASE, onRepeatPlease, AutoHideEvent);
			addContextListener(AutoHideEvent.WAIT_ME, onWaitTarget, AutoHideEvent);
			addContextListener(AutoHideEvent.FORGET_ME, onForgetTarget, AutoHideEvent);
			
			onMediaPlayerStateChange();
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
			if (oldMediaElement) {
				oldMediaElement.metadata.removeEventListener(MetadataEvent.VALUE_ADD, onMetadataChange);
				oldMediaElement.metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
				oldMediaElement.metadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onMetadataChange);
			}
			if (media) {
				media.metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataChange);
				media.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
				media.metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataChange);
			}
		}
		
		protected function set visible(value:Boolean):void {
			if (_visible == value) return;
			_visible = value;
			if (!_visible && (isFullScreen || !isMouseLeave)) {
				Mouse.hide();
			} else {
				Mouse.show();
			}
			dispatchShowHideEvent();
		}
		
		protected function resetAutoHideTimer():void {
			isAutoHideComplete = false;
			autoHideTimer.reset();
			autoHideTimer.start();
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent = null):void {
			switch (player.state) {
				case MediaPlayerState.PLAYING:
					isPlaying = true;
				case MediaPlayerState.READY:
					isReady = true;
					checkVisibility();
					break;
			}
			if (isReady && isPlaying) {
				player.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			}
		}
		
		protected function onPlayStateChange(event:PlayEvent):void {
			isPlaying = event.playState == PlayState.PLAYING;
			checkVisibility();
		}
		
		protected function onAutoHideTimer(event:TimerEvent):void {
			isAutoHideComplete = true;
			isMouseMove = false;
			checkVisibility();
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			isMouseMove = true;
			resetAutoHideTimer();
			if (isMouseLeave || !_visible) {
				isMouseLeave = false;
				checkVisibility();
			}
		}
		
		protected function onMouseLeave(event:Event):void {
			isMouseLeave = true;
			checkVisibility();
		}
		
		protected function onFullScreen(event:FullScreenEvent):void {
			isFullScreen = event.fullScreen;
			checkVisibility();
		}
		
		protected function onWaitTarget(event:AutoHideEvent):void {
			waitTargets[event.hideTarget] = true;
			hasWaitTarget = true;
			resetAutoHideTimer();
		}
		
		protected function onForgetTarget(event:AutoHideEvent):void {
			delete waitTargets[event.hideTarget];
			for (var i:String in waitTargets) {
				return;
			}
			hasWaitTarget = false;
			checkVisibility();
		}
		
		protected function onMetadataChange(event:MetadataEvent):void {
			if (event.key != "Advertisement") return;
			isAdvertisement = event.type != MetadataEvent.VALUE_REMOVE;
			checkVisibility();
		}
		
		protected function onRepeatPlease(event:AutoHideEvent = null):void {
			dispatchShowHideEvent();
		}
		
		protected function checkVisibility():void {
//			trace(isReady, isFullScreen, isMouseMove, isMouseLeave, isAutoHideComplete, isPlaying, isAdvertisement, hasWaitTarget);
			
			visible =
				isReady
				&&
				(
					(!isPlaying && !isAdvertisement)
					||
					hasWaitTarget
					||
					(!isFullScreen && !isMouseLeave && !isAutoHideComplete)
					||
					(isFullScreen && isMouseMove && !isAutoHideComplete)
				);
			
			if (_visible) {
				resetAutoHideTimer();
			}
		}
		
		protected function dispatchShowHideEvent():void {
			dispatch(new AutoHideEvent(_visible ? AutoHideEvent.SHOW : AutoHideEvent.HIDE));
		}
		
	}
	
}
