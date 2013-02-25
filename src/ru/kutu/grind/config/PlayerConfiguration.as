package ru.kutu.grind.config {

	import org.osmf.layout.ScaleMode;
	import org.osmf.net.StreamType;

	public class PlayerConfiguration {

		public var src:String = "";
		public var metadata:Object = {};
		public var resource:Object = {streamType:StreamType.LIVE_OR_RECORDED};
		public var controlBarAutoHide:Boolean = true;
		public var controlBarFullScreenAutoHide:Boolean = true;
		public var controlBarAutoHideTimeout:Number = 3.0;
		public var scaleMode:String = ScaleMode.LETTERBOX;
		public var plugins:Object = {};
		public var haltOnError:Boolean = false;
		public var javascriptCallbackFunction:String;
		public var enableStageVideo:Boolean = true;

	}

}
