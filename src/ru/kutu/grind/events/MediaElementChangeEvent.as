package ru.kutu.grind.events {

	import flash.events.Event;

	public class MediaElementChangeEvent extends Event {

		public static const MEDIA_ELEMENT_CHANGED:String = "mediaElementChanged";

		public function MediaElementChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new MediaElementChangeEvent(type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("MediaElementChangeEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}

}
