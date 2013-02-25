package ru.kutu.grind.views.api {
	
	import ru.kutu.grind.views.api.helpers.IEnabled;
	
	public interface IControlBarView extends IEnabled {
		
		function get shown():Boolean;
		function set shown(value:Boolean):void;
		
	}
	
}
