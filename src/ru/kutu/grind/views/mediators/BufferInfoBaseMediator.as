package ru.kutu.grind.views.mediators {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.BufferEvent;
	
	import ru.kutu.grind.views.api.IBufferInfo;
	
	public class BufferInfoBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var view:IBufferInfo;
		
		protected var bufferChangeTimer:Timer;
		
		override public function initialize():void {
			super.initialize();
			player.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
			player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			bufferChangeTimer = new Timer(100);
			bufferChangeTimer.addEventListener(TimerEvent.TIMER, onBufferChangeTimer);
		}
		
		protected function onBufferChangeTimer(event:TimerEvent):void {
			if (!player.buffering) {
				bufferChangeTimer.reset();
			} else {
				view.data = player.bufferLength;
			}
		}
		
		protected function onBufferTimeChange(event:BufferEvent):void {
			view.bufferTime = event.bufferTime;
		}
		
		protected function onBufferingChange(event:BufferEvent):void {
			view.data = event.buffering ? player.bufferLength : null;
			bufferChangeTimer.reset();
			if (event.buffering) {
				bufferChangeTimer.start();
			}
		}
		
	}
	
}
