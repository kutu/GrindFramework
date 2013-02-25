package ru.kutu.grind.views.api {
	
	public interface IMainView {
		
		function set errorText(value:String):void;
		
		function initializing():void;
		function ready():void;
		function error():void;
		
	}
	
}
