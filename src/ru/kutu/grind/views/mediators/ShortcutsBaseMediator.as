package ru.kutu.grind.views.mediators {
	
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.net.StreamType;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.MediaTraitType;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	
	import ru.kutu.grind.config.PlayerConfiguration;
	import ru.kutu.grind.events.PlayerViewEvent;
	import ru.kutu.grind.media.GrindMediaPlayerBase;
	import ru.kutu.grind.views.api.IPlayerView;
	
	public class ShortcutsBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IPlayerView;
		[Inject] public var configuration:PlayerConfiguration;
		
		protected var dblClickTime:Number;
		protected var isShift:Boolean;
		protected var isCtrl:Boolean;
		
		override public function initialize():void {
			super.initialize();
			addContextListener(PlayerViewEvent.CLICK, onPlayerVideoAreaClick);
			contextView.view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			contextView.view.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		protected function onPlayerVideoAreaClick(event:PlayerViewEvent):void {
			// play / pause
			if (player is GrindMediaPlayerBase) {
				var streamType:String = (player as GrindMediaPlayerBase).streamType;
			}
			// only if streamType is recorded
			if (!streamType ||
				streamType == StreamType.LIVE_OR_RECORDED ||
				streamType == StreamType.RECORDED ||
				(streamType == StreamType.DVR && !(media.getTrait(MediaTraitType.DVR) as DVRTrait).isRecording)
			) {
				if (player.playing) {
					if (player.canPause)
						player.pause();
				} else if (player.canPlay) {
					player.play();
				}
			}
			
			// dblClick => fullscreen
			if (!isNaN(dblClickTime) && getTimer() - dblClickTime < 500) {
				dblClickTime = NaN;
				onFullScreenRequest();
			} else {
				dblClickTime = getTimer();
			}
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				// volume up
				case Keyboard.UP:
					if (player.muted) {
						player.muted = false;
						player.volume = .1;
					} else {
						player.volume = (Math.round(player.volume * 10) + 1) * .1;
					}
					break;
				
				// volume down
				case Keyboard.DOWN:
					if (!player.muted) {
						player.volume = (Math.round(player.volume * 10) - 1) * .1;
						if (player.volume <= 0) {
							player.muted = true;
						}
					}
					break;
				
				// seek
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					var seekDuration:Number = isShift ? 5 : isCtrl ? 60 : 10;
					var seekTo:Number = player.currentTime + (event.keyCode == Keyboard.RIGHT ? 1.0 : -1.0) * seekDuration;
					if (seekTo < 0) seekTo = 0;
					if (!isNaN(player.duration) && seekTo > player.duration) seekTo = player.duration - 5.0;
					if (player.canSeek && !player.seeking && player.canSeekTo(seekTo)) {
						player.seek(seekTo);
					}
					break;
				
				case Keyboard.SHIFT:
					isShift = true;
					break;
				
				case Keyboard.CONTROL:
					isCtrl = true;
					break;
			}
		}
		
		protected function onKeyUp(event:KeyboardEvent):void {
			var l:LayoutMetadata;
			
			switch (event.keyCode) {
				// play/pause
				case Keyboard.SPACE:
					if (player.playing) {
						if (player.canPause)
							player.pause();
					} else if (player.canPlay) {
						player.play();
					}
					break;
				
				// fullscreen
				case Keyboard.F:
					onFullScreenRequest();
					break;
				
				// scale mode
				case Keyboard.S:
					var gmp:GrindMediaPlayerBase = player as GrindMediaPlayerBase;
					if (gmp) {
						const scaleModes:Vector.<String> = new <String>[
							ScaleMode.LETTERBOX,
							ScaleMode.ZOOM,
							ScaleMode.STRETCH,
							ScaleMode.NONE
						];
						var i:int = scaleModes.indexOf(gmp.scaleMode);
						gmp.scaleMode = i == -1 ? scaleModes[0] : scaleModes[++i % scaleModes.length];
					}
					break;
				
				case Keyboard.SHIFT:
					isShift = false;
					break;
				
				case Keyboard.CONTROL:
					isCtrl = false;
					break;
			}
		}
		
		protected function onFullScreenRequest():void {
			if (contextView.view.stage.allowsFullScreen) {
				contextView.view.stage.displayState =
					contextView.view.stage.displayState == StageDisplayState.NORMAL
					? StageDisplayState.FULL_SCREEN
					: StageDisplayState.NORMAL;
			}
		}
		
	}
	
}
