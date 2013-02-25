package ru.kutu.grind.views.mediators {
	
	import flash.events.Event;
	
	import ru.kutu.grind.events.ControlBarMenuChangeEvent;
	import ru.kutu.grind.vos.SelectorVO;
	
	public class ControlBarMenuBaseMediator extends MediaControlBaseMediator {
		
		protected const selectors:Vector.<SelectorVO> = new <SelectorVO>[];
		
		override public function initialize():void {
			super.initialize();
			addViewListener(ControlBarMenuChangeEvent.CHANGE, onMenuChange, ControlBarMenuChangeEvent);
			onSwitchChange();
		}
		
		protected function onNumStreamChange(event:Event = null):void {
			onSwitchChange();
		}
		
		protected function onSwitchChange(event:Event = null):void {
		}
		
		protected function getSelectorVOByIndex(index:int):SelectorVO {
			var len:int = selectors.length;
			for (var i:int = 0; i < len; ++i) {
				var vo:SelectorVO = selectors[i] as SelectorVO;
				if (vo.index == index) return vo;
			}
			return null;
		}
		
		protected function onMenuChange(event:ControlBarMenuChangeEvent):void {
		}
		
		protected function processLabelForSelectorVO(item:Object):String {
			return null;
		}
		
	}
	
}
