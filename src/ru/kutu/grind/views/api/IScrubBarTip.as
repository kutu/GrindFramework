package ru.kutu.grind.views.api {
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import ru.kutu.grind.views.api.helpers.IData;
	
	public interface IScrubBarTip extends IData {
		
		function get thumbnailsContainer():DisplayObjectContainer;
		function updatePosition(globalPoint:Point):void;
		
		function normal(hasThumbnails:Boolean, playTransition:Boolean):void;
		function hidden(hasThumbnails:Boolean, playTransition:Boolean):void;
		
	}
	
}
