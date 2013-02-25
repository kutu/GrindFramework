package ru.kutu.grind.views.mediators {
	
	import org.osmf.events.AudioEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	
	import ru.kutu.grind.config.LocalSettings;
	import ru.kutu.grind.events.AutoHideEvent;
	import ru.kutu.grind.events.VolumeComponentEvent;
	import ru.kutu.grind.views.api.IVolumeComponent;
	
	public class VolumeComponentBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var view:IVolumeComponent;
		[Inject] public var ls:LocalSettings;
		
		protected var sliderChanging:Boolean;
		
		private var _requiredTraits:Vector.<String> = new <String>[MediaTraitType.AUDIO];
		
		override public function initialize():void {
			super.initialize();
			player.volume = ls.volume;
			player.muted = ls.volumeMuted;
			player.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			player.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
			addViewListener(VolumeComponentEvent.BUTTON_CLICK, onButtonClick, VolumeComponentEvent);
			addViewListener(VolumeComponentEvent.SLIDER_CHANGE_START, onSliderChangeStart, VolumeComponentEvent);
			addViewListener(VolumeComponentEvent.SLIDER_CHANGE_END, onSliderChangeEnd, VolumeComponentEvent);
			addViewListener(VolumeComponentEvent.SLIDER_CHANGE, onSliderChange, VolumeComponentEvent);
			updateVolumeSlider();
		}
		
		override protected function get requiredTraits():Vector.<String> {
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void {
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
		}
		
		protected function onVolumeChange(event:AudioEvent):void {
			if (sliderChanging) return;
			updateVolumeSlider();
			ls.volume = player.volume;
		}
		
		protected function onMutedChange(event:AudioEvent):void {
			if (sliderChanging) return;
			updateVolumeSlider();
			ls.volumeMuted = player.muted;
		}
		
		protected function onButtonClick(event:VolumeComponentEvent):void {
			if (player.muted && player.volume == 0) {
				player.volume = 1;
			}
			player.muted = !player.muted;
		}
		
		protected function onSliderChangeStart(event:VolumeComponentEvent):void {
			sliderChanging = true;
			dispatch(new AutoHideEvent(AutoHideEvent.WAIT_ME, "volumeBar"));
		}
		
		protected function onSliderChangeEnd(event:VolumeComponentEvent):void {
			onSliderChange();
			sliderChanging = false;
			dispatch(new AutoHideEvent(AutoHideEvent.FORGET_ME, "volumeBar"));
		}
		
		protected function onSliderChange(event:VolumeComponentEvent = null):void {
			player.volume = view.volume;
			player.muted = player.volume <= 0;
			updateVolumeSlider();
			ls.volume = player.volume;
			ls.volumeMuted = player.muted;
		}
		
		protected function updateVolumeSlider():void {
			view.volume = player.muted ? 0 : player.volume;
		}
		
	}
	
}
