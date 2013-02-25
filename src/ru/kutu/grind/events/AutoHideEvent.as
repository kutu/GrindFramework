package ru.kutu.grind.events {

	import flash.events.Event;

	public class AutoHideEvent extends Event {

		public static const SHOW:String = "autoHide.show";
		public static const HIDE:String = "autoHide.hide";
		public static const REPEAT_PLEASE:String = "autoHide.repeatPlease";
		public static const WAIT_ME:String = "autoHide.waitMe";
		public static const FORGET_ME:String = "autoHide.forgetMe";

		private var _hideTarget:String;

		public function AutoHideEvent(type:String, hideTarget:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_hideTarget = hideTarget;
			super(type, bubbles, cancelable);
		}

		public function get hideTarget():String { return _hideTarget }

		override public function clone():Event {
			return new AutoHideEvent(_hideTarget, type, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("AutoHideEvent", "type", "hideTarget", "bubbles", "cancelable", "eventPhase");
		}

	}

}
