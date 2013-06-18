package ru.kutu.grind.log {

	import flash.utils.Dictionary;
	
	import org.osmf.logging.Logger;
	import org.osmf.logging.LoggerFactory;
	
	import robotlegs.bender.framework.api.IContext;

	public class GrindLoggerFactory extends LoggerFactory {

		[Inject] public var context:IContext;
		
		protected var loggers:Dictionary;

		public function GrindLoggerFactory() {
			super();
			loggers = new Dictionary();
		}

		override public function getLogger(category:String):Logger {
			var logger:Logger = loggers[category];

			if (!logger) {
				logger = new GrindLogger(category, context.getLogger(category.replace(/(?:.*\.|^)(.*)/, "[$1]")));
				loggers[category] = logger;
			}

			return logger;
		}

	}

}
