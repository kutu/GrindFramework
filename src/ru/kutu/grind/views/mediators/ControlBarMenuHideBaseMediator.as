package ru.kutu.grind.views.mediators {
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	import ru.kutu.grind.events.AutoHideEvent;
	import ru.kutu.grind.events.ControlBarMenuEvent;
	import ru.kutu.grind.views.api.IControlBarMenuButtonHide;
	
	public class ControlBarMenuHideBaseMediator extends Mediator {
		
		[Inject] public var view:IControlBarMenuButtonHide;
		
		override public function initialize():void {
			super.initialize();
			addContextListener(AutoHideEvent.HIDE, onAutoHide, AutoHideEvent);
			addViewListener(ControlBarMenuEvent.DROPDOWN_OPEN, onDropDownOpen, ControlBarMenuEvent);
			addViewListener(ControlBarMenuEvent.DROPDOWN_CLOSE, onDropDownClose, ControlBarMenuEvent);
		}
		
		private function onAutoHide(event:AutoHideEvent):void {
			view.closeDropDown(false);
		}
		
		private function onDropDownOpen(event:ControlBarMenuEvent):void {
			dispatch(new AutoHideEvent(AutoHideEvent.WAIT_ME, String(view)));
		}
		
		private function onDropDownClose(event:ControlBarMenuEvent):void {
			dispatch(new AutoHideEvent(AutoHideEvent.FORGET_ME, String(view)));
		}
		
	}
	
}
