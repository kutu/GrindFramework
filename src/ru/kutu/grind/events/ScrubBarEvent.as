package ru.kutu.grind.events {

	import flash.events.Event;

	public class ScrubBarEvent extends Event {

		public static const SLIDER_CHANGE:String = "scrubBar.sliderChange";
		public static const SLIDER_CHANGE_START:String = "scrubBar.sliderChangeStart";
		public static const SLIDER_CHANGE_END:String = "scrubBar.sliderChangeEnd";
		public static const SHOW_TIP:String = "scrubBarTip.show";
		public static const HIDE_TIP:String = "scrubBarTip.hide";
		public static const HIDE_TIP_IMMEDIATE:String = "scrubBarTip.hideImmediate";

		public function ScrubBarEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new ScrubBarEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("ScrubBarEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
