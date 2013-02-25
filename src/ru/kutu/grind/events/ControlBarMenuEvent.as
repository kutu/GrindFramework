package ru.kutu.grind.events {

	import flash.events.Event;

	public class ControlBarMenuEvent extends Event {

		public static const DROPDOWN_OPEN:String = "controlBarMenu.dropdownOpen";
		public static const DROPDOWN_CLOSE:String = "controlBarMenu.dropdownClose";

		public function ControlBarMenuEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new ControlBarMenuEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("ControlBarMenuEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
