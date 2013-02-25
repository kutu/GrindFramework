package ru.kutu.grind.views.api {
	
	import flash.events.IEventDispatcher;
	
	import ru.kutu.grind.views.api.helpers.IVisible;
	import ru.kutu.grind.vos.SelectorVO;
	
	public interface IControlBarMenuButton extends IEventDispatcher, IVisible {
		
		function get selectedIndex():int;
		function set selectedIndex(value:int):void;
		
		function openDropDown():void;
		function closeDropDown(commit:Boolean):void;
		function setSelectors(list:Vector.<SelectorVO>):void;
		
	}
	
}
