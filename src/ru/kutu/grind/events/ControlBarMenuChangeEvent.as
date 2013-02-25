package ru.kutu.grind.events {

	import flash.events.Event;

	public class ControlBarMenuChangeEvent extends Event {

		public static const CHANGE:String = "controlBarMenu.change";

		private var _index:int;

		public function ControlBarMenuChangeEvent(type:String, index:int, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_index = index;
		}

		public function get index():int { return _index }

		override public function clone():Event {
			return new ControlBarMenuChangeEvent(type, index, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("ControlBarMenuChangeEvent", "type", "index", "bubbles", "cancelable", "eventPhase");
		}

	}

}
