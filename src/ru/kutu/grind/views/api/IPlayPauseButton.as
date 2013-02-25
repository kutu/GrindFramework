package ru.kutu.grind.views.api {
	
	import ru.kutu.grind.views.api.helpers.IEnabled;
	
	public interface IPlayPauseButton extends IEnabled {
		
		function set playState(value:String):void;
		
	}
	
}
