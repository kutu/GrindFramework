package ru.kutu.grind.events {

	import flash.events.Event;

	public class LoadMediaEvent extends Event {

		public static const LOAD_MEDIA:String = "player.loadMedia";

		public function LoadMediaEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new LoadMediaEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("LoadMediaEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
