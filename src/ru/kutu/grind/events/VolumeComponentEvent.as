package ru.kutu.grind.events {

	import flash.events.Event;

	public class VolumeComponentEvent extends Event {

		public static const BUTTON_CLICK:String = "volumeComponent.volumeButtonClick";
		public static const SLIDER_CHANGE:String = "volumeComponent.volumeSliderChange";
		public static const SLIDER_CHANGE_START:String = "volumeComponent.volumeSliderChangeStart";
		public static const SLIDER_CHANGE_END:String = "volumeComponent.volumeSliderChangeEnd";

		public function VolumeComponentEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new VolumeComponentEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("VolumeComponentEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
