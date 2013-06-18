package ru.kutu.grind.views.mediators {
	
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.traits.MediaTraitType;
	
	import ru.kutu.grind.events.StatInfoEvent;
	import ru.kutu.grind.views.api.IStatInfo;
	
	public class StatInfoBaseMediator extends MediaControlBaseMediator {
		
		protected static var UPDATE_INTERVAL:uint = 500;
		
		[Inject] public var view:IStatInfo;
		
		protected const qosInfos:Vector.<QoSInfo> = new Vector.<QoSInfo>();
		protected var updateTimer:Timer;
		
		protected var _visible:Boolean;
		
		override public function initialize():void {
			super.initialize();
			addContextListener(StatInfoEvent.SHOW, onShow, StatInfoEvent);
			addContextListener(StatInfoEvent.HIDE, onHide, StatInfoEvent);
			addContextListener(StatInfoEvent.TOGGLE, onToggle, StatInfoEvent);
			addViewListener(StatInfoEvent.HIDE, onHide, StatInfoEvent);
			
			updateTimer = new Timer(UPDATE_INTERVAL);
			updateTimer.addEventListener(TimerEvent.TIMER, onUpdateTimer);
			
			player.addEventListener(QoSInfoEvent.QOS_UPDATE, onQoSUpdate);
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
			super.processMediaElementChange(oldMediaElement);
			view.clear();
			qosInfos.length = 0;
		}
		
		protected function set visible(value:Boolean):void {
			if (_visible == value) return;
			_visible = value;
			view.visible = value;
			updateTimer.reset();
			if (value) {
				updateQoSInfo();
				updateTimer.start();
			} else {
				view.clear();
			}
		}
		
		protected function updateQoSInfo():void {
			var vs:VideoSurface = player.displayObject as VideoSurface;
			
			var lt:NetStreamLoadTrait, ns:NetStream;
			if (media.hasTrait(MediaTraitType.LOAD)) {
				lt = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				if (lt) {
					ns = lt.netStream;
				}
			}
			
			view.update(vs, ns, qosInfos.length ? qosInfos.slice() : null);
			qosInfos.length = 0;
		}
		
		protected function onQoSUpdate(event:QoSInfoEvent):void {
			qosInfos.push(event.qosInfo);
			while (qosInfos.length > 10) qosInfos.shift();
		}
		
		protected function onUpdateTimer(event:TimerEvent):void {
			updateQoSInfo();
		}
		
		protected function onShow(event:StatInfoEvent):void {
			visible = true;
		}
		
		protected function onHide(event:StatInfoEvent):void {
			visible = false;
		}
		
		protected function onToggle(event:StatInfoEvent):void {
			visible = !_visible;
		}
		
	}
	
}
