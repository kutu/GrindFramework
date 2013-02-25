package ru.kutu.grind.views.api {
	
	import flash.events.IEventDispatcher;
	
	import ru.kutu.grind.views.api.helpers.IEnabled;
	import ru.kutu.grind.views.api.helpers.IVisible;
	
	public interface IScrubBar extends IEnabled, IEventDispatcher, IVisible {
		
		function get value():Number;
		function set value(value:Number):void;
			
		function get maximum():Number;
		function set maximum(value:Number):void;
			
		function get percentLoaded():Number;
		function set percentLoaded(value:Number):void;
		
		function get tip():IScrubBarTip;
		
		function hideTip(immediate:Boolean=false):void;
		
	}
	
}
