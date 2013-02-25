package ru.kutu.grind.views.mediators  {
	
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	import robotlegs.bender.extensions.contextView.ContextView;
	
	import ru.kutu.grind.views.api.IFullScreenButton;
	
	public class FullscreenButtonBaseMediator extends Mediator {
		
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IFullScreenButton;
		
		override public function initialize():void {
			if (contextView.view.stage.allowsFullScreen) {
				addViewListener(MouseEvent.CLICK, onClick);
			} else {
				view.unavailable();
			}
		}
		
		protected function onClick(event:MouseEvent):void {
			contextView.view.stage.displayState =
				contextView.view.stage.displayState == StageDisplayState.NORMAL
				? StageDisplayState.FULL_SCREEN
				: StageDisplayState.NORMAL;
		}
		
	}
	
}
