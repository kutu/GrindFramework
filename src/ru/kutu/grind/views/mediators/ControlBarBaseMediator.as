package ru.kutu.grind.views.mediators {

	import flash.events.FullScreenEvent;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	
	import ru.kutu.grind.config.PlayerConfiguration;
	import ru.kutu.grind.events.AutoHideEvent;
	import ru.kutu.grind.views.api.IControlBarView;

	public class ControlBarBaseMediator extends MediaControlBaseMediator {

		[Inject] public var injector:Injector;
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IControlBarView;

		protected var autoHide:Boolean;
		protected var fullScreenAutoHide:Boolean;
		protected var isFullScreen:Boolean;

		override public function initialize():void {
			super.initialize();
			var configuration:PlayerConfiguration = injector.getInstance(PlayerConfiguration);
			autoHide = configuration.controlBarAutoHide;
			fullScreenAutoHide = configuration.controlBarFullScreenAutoHide;
			if (autoHide || fullScreenAutoHide) {
				if (autoHide != fullScreenAutoHide) {
					contextView.view.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
				}
				addContextListener(AutoHideEvent.SHOW, onAutoShow, AutoHideEvent);
				addContextListener(AutoHideEvent.HIDE, onAutoHide, AutoHideEvent);
				dispatch(new AutoHideEvent(AutoHideEvent.REPEAT_PLEASE));
			} else {
				view.shown = true;
			}
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			view.enabled = false;
		}

		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent = null):void {
			switch (player.state) {
				case MediaPlayerState.PLAYING:
				case MediaPlayerState.READY:
					view.enabled = true;
					player.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
					break;
			}
		}
		
		protected function onFullScreen(event:FullScreenEvent):void {
			isFullScreen = event.fullScreen;
			if (isFullScreen) {
				if (!fullScreenAutoHide && !view.shown) {
					view.shown = true;
				}
			} else {
				if (!autoHide && !view.shown) {
					view.shown = true;
				}
			}
		}

		private function onAutoShow(event:AutoHideEvent):void {
			view.shown = true;
		}

		private function onAutoHide(event:AutoHideEvent):void {
			if (
				(isFullScreen && fullScreenAutoHide)
				||
				(!isFullScreen && autoHide)
			) {
				view.shown = false;
			}
		}

	}

}
