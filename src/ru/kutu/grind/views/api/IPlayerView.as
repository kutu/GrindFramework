package ru.kutu.grind.views.api {
	
	import flash.display.DisplayObjectContainer;
	
	public interface IPlayerView {
		
		function get mediaPlayerContainer():DisplayObjectContainer;
		
		function get controlBarAutoHide():Boolean;
		function set controlBarAutoHide(value:Boolean):void;
		
	}
	
}
