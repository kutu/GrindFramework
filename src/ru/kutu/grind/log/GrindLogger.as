package ru.kutu.grind.log {
	
	import org.osmf.logging.Logger;
	
	import robotlegs.bender.framework.api.ILogger;
	
	public class GrindLogger extends Logger {
		
		protected var logger:ILogger;
		
		public function GrindLogger(category:String, logger:ILogger) {
			super(category);
			this.logger = logger;
		}
		
		override public function debug(message:String, ...rest):void {
			logger.debug(message, rest);
		}
		
		override public function info(message:String, ...rest):void {
			logger.info(message, rest);
		}
		
		override public function warn(message:String, ...rest):void {
			logger.warn(message, rest);
		}
		
		override public function error(message:String, ...rest):void {
			logger.error(message, rest);
		}
		
		override public function fatal(message:String, ...rest):void {
			logger.fatal(message, rest);
		}
		
	}
	
}
