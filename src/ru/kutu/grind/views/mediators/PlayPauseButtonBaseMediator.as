package ru.kutu.grind.views.mediators  {
	
	import flash.events.MouseEvent;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	import ru.kutu.grind.views.api.IPlayPauseButton;
	
	public class PlayPauseButtonBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var view:IPlayPauseButton;
		
		protected var playable:PlayTrait;
		
		private var _requiredTraits:Vector.<String> = new <String>[MediaTraitType.PLAY];
		
		override protected function get requiredTraits():Vector.<String> {
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void {
			view.enabled = true;
			addViewListener(MouseEvent.CLICK, onClick);
			if (element) {
				playable = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
				playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
				onPlayStateChange();
			}
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
			view.enabled = false;
			removeViewListener(MouseEvent.CLICK, onClick);
			if (playable) {
				playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
				playable = null;
			}
		}
		
		protected function onPlayStateChange(event:PlayEvent = null):void {
			view.playState = playable.playState;
		}
		
		protected function onClick(event:MouseEvent):void {
			var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playable.playState == PlayState.PLAYING && playable.canPause) {
				playable.pause();
			} else {
				playable.play();
			}
		}
		
	}
	
}
