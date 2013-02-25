package ru.kutu.grind.config {
	
	import org.osmf.player.debug.LogHandler;
	import org.osmf.player.debug.LogMessage;
	
	import robotlegs.bender.framework.api.ILogger;
	
	public class GrindLogHandler extends LogHandler {
		
		[Inject] public var logger:ILogger;
		
		public function GrindLogHandler(ignoreEmptyValues:Boolean=true) {
			super(ignoreEmptyValues);
		}
		
		override public function handleLogMessage(logMessage:LogMessage):void {
			super.handleLogMessage(logMessage);
			logger.info("{0} {1} {2}", [logMessage.level, logMessage.category, logMessage.formatedMessage]);
		}
		
	}
	
}
