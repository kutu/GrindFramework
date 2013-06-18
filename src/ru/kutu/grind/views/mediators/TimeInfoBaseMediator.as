package ru.kutu.grind.views.mediators {
	
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	
	import ru.kutu.grind.utils.FormatTime;
	import ru.kutu.grind.views.api.ITimeInfo;
	
	public class TimeInfoBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var view:ITimeInfo;
		
		protected var hasDuration:Boolean;
		protected var hasTime:Boolean;
		
		override public function initialize():void {
			super.initialize();
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
			hasDuration = hasTime = false;
			view.currentTime = FormatTime.formatTime(0);
			validate();
		}
		
		override protected function onStreamTypeChange(streamType:String):void {
			view.streamType = streamType;
		}
		
		protected function onDurationChange(event:TimeEvent):void {
			view.duration = FormatTime.formatTime(event.time);
			if (!hasDuration) {
				hasDuration = true;
				validate();
			}
		}
		
		protected function onCurrentTimeChange(event:TimeEvent):void {
			view.currentTime = FormatTime.formatTime(event.time);
			if (!hasTime) {
				hasTime = true;
				validate();
			}
		}
		
		protected function validate():void {
			view.visible = hasDuration;
		}
		
	}
	
}
