package ru.kutu.grind.config {
	
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import robotlegs.bender.framework.api.ILogger;
	
	public class LocalSettings {
		
		public static const VOLUME:String = "volume";
		public static const VOLUME_MUTED:String = "volumeMuted";
		public static const QUALITY_PREFER_BITRATE:String = "qualityPreferBitrate";
		public static const QUALITY_PREFER_HEIGHT:String = "qualityPreferHeight";
		public static const QUALITY_AUTO_SWITCH:String = "qualityAutoSwitch";
		
		[Inject] public var logger:ILogger;
		
		protected const LSO_NAME:String = "grindPlayer";
		
		protected const lso:SharedObject = SharedObject.getLocal(LSO_NAME, "/");
		
		protected var saveSettingsTimer:Timer;
		
		protected var _volume:Number = 1.0;
		protected var _volumeMuted:Boolean = false;
		
		protected var _qualityPreferBitrate:Number;
		protected var _qualityPreferHeight:int = 480;
		protected var _qualityAutoSwitch:Boolean = true;
		
		public function LocalSettings() {
			saveSettingsTimer = new Timer(1000, 1);
			saveSettingsTimer.addEventListener(TimerEvent.TIMER, onSaveSettingsTimer);
			loadSettings();
		}
		
		public function get volume():Number { return _volume }
		public function set volume(value:Number):void {
			if (_volume == value) return;
			_volume = value;
			lso.data[VOLUME] = value;
			flushSettings();
		}
		
		public function get volumeMuted():Boolean { return _volumeMuted }
		public function set volumeMuted(value:Boolean):void {
			if (_volumeMuted == value) return;
			_volumeMuted = value;
			lso.data[VOLUME_MUTED] = value;
			flushSettings();
		}
		
		public function get qualityPreferBitrate():Number { return _qualityPreferBitrate }
		public function set qualityPreferBitrate(value:Number):void {
			if (value <= 0) return;
			if (_qualityPreferBitrate == value) return;
			_qualityPreferBitrate = value;
			lso.data[QUALITY_PREFER_BITRATE] = value;
			flushSettings();
		}
		
		public function get qualityPreferHeight():int { return _qualityPreferHeight }
		public function set qualityPreferHeight(value:int):void {
			if (value <= 0) return;
			if (_qualityPreferHeight == value) return;
			_qualityPreferHeight = value;
			lso.data[QUALITY_PREFER_HEIGHT] = value;
			flushSettings();
		}
		
		public function get qualityAutoSwitch():Boolean { return _qualityAutoSwitch }
		public function set qualityAutoSwitch(value:Boolean):void {
			if (_qualityAutoSwitch == value) return;
			_qualityAutoSwitch = value;
			lso.data[QUALITY_AUTO_SWITCH] = value;
			flushSettings();
		}
		
		protected function loadSettings():void {
			if (VOLUME in lso.data && !isNaN(lso.data[VOLUME])) {
				_volume = lso.data[VOLUME];
			}
			if (VOLUME_MUTED in lso.data) {
				_volumeMuted = lso.data[VOLUME_MUTED];
			}
			
			if (QUALITY_PREFER_BITRATE in lso.data && lso.data[QUALITY_PREFER_BITRATE] > 0) {
				_qualityPreferBitrate = lso.data[QUALITY_PREFER_BITRATE];
			}
			if (QUALITY_PREFER_HEIGHT in lso.data && lso.data[QUALITY_PREFER_HEIGHT] > 0) {
				_qualityPreferHeight = lso.data[QUALITY_PREFER_HEIGHT];
			}
			if (QUALITY_AUTO_SWITCH in lso.data) {
				_qualityAutoSwitch = lso.data[QUALITY_AUTO_SWITCH];
			}
		}
		
		protected function flushSettings():void {
			saveSettingsTimer.reset();
			saveSettingsTimer.start();
		}
		
		protected function onSaveSettingsTimer(event:TimerEvent):void {
			var flushStatus:String = lso.flush();
			CONFIG::LOGGING {
				logger.info("flushed with status: {0}", [flushStatus]);
			}
		}
		
	}
	
}
