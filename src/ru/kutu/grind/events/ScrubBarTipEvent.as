package ru.kutu.grind.events {

	import flash.events.Event;
	import flash.geom.Point;

	public class ScrubBarTipEvent extends Event {

		public static const TIP_DATA_UPDATE:String = "scrubBarTip.dataUpdate";

		private var _time:Number;
		private var _globalPoint:Point;

		public function ScrubBarTipEvent(type:String, time:Number, globalPoint:Point, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_time = time;
			_globalPoint = globalPoint;
		}

		public function get time():Number { return _time }
		public function get globalPoint():Point { return _globalPoint }

		override public function clone():Event {
			return new ScrubBarTipEvent(type, _time, _globalPoint, bubbles, cancelable);
		}

		override public function toString():String {
			return formatToString("ScrubBarTipEvent", "type", "time", "globalPoint", "bubbles", "cancelable", "eventPhase");
		}

	}

}
