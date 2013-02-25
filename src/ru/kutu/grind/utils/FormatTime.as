package ru.kutu.grind.utils {
	
	public class FormatTime {
		
		public static function formatTime(time:Number):String {
			var h:Number, m:Number, s:Number;
			var seconds:Number = time;
			seconds = Math.floor(isNaN(seconds) ? 0.0 : Math.max(0.0, seconds));
			h = Math.floor(seconds / 3600.0);
			m = Math.floor(seconds % 3600.0 / 60.0);
			s = seconds % 60.0;
			return prettyPrintSeconds(h, m, s, h > 0 || m > 9, h > 0);
		}
		
		private static function prettyPrintSeconds(h:Number, m:Number, s:Number, leadingMinutes:Boolean = false, leadingHours:Boolean = false):String {
			return ((h > 0.0 || leadingHours) ? (h + ":") : "")
				+ (((h > 0.0 || leadingMinutes) && m < 10.0) ? "0" : "")
					+ m + ":" 
					+ (s < 10.0 ? "0" : "") 
					+ s;
		}
		
	}
	
}
