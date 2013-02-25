package ru.kutu.grind.views.api {
	
	import ru.kutu.grind.views.api.helpers.IVisible;
	
	public interface ITimeInfo extends IVisible {
		
		function set currentTime(value:String):void;
		function set duration(value:String):void;
		function set streamType(value:String):void;
		
	}
	
}
