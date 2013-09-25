package ru.kutu.grind.views.mediators {
	
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	import robotlegs.bender.extensions.contextView.ContextView;
	
	import ru.kutu.grind.views.api.IFullScreenState;
	
	public class FullScreenStateMediator extends Mediator {
		
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IFullScreenState;
		
		override public function initialize():void {
			contextView.view.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			view.fullScreen = contextView.view.stage.displayState != StageDisplayState.NORMAL;
		}
		
		protected function onFullScreen(event:FullScreenEvent):void {
			view.fullScreen = event.fullScreen;
		}
		
	}
	
}
