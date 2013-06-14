package ru.kutu.grind.events {

	import flash.events.Event;

	public class PlayerViewEvent extends Event {

		public static const RESIZE:String = "playerView.resize";
		public static const CLICK:String = "playerView.click";

		public function PlayerViewEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new PlayerViewEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("PlayerViewEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
