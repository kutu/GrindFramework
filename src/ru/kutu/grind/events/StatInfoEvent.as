package ru.kutu.grind.events {

	import flash.events.Event;

	public class StatInfoEvent extends Event {

		public static const SHOW:String = "statInfo.show";
		public static const HIDE:String = "statInfo.hide";
		public static const TOGGLE:String = "statInfo.toggle";

		public function StatInfoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new StatInfoEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("StatInfoEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
