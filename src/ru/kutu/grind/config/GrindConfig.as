package ru.kutu.grind.config  {
	
	import flash.external.ExternalInterface;
	
	import org.osmf.logging.Log;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.player.configuration.ConfigurationFlashvarsDeserializer;
	import org.osmf.player.configuration.ConfigurationLoader;
	import org.osmf.player.configuration.ConfigurationProxy;
	import org.osmf.player.configuration.ConfigurationXMLDeserializer;
	
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IInjector;
	
	import ru.kutu.grind.log.GrindLoggerFactory;
	import ru.kutu.grind.log.JSLogTarget;
	import ru.kutu.grind.media.GrindMediaFactoryBase;
	import ru.kutu.grind.media.GrindMediaPlayerBase;
	
	public class GrindConfig implements IConfig {
		
		[Inject] public var injector:IInjector;
		[Inject] public var context:IContext;
		
		public function configure():void {
			CONFIG::LOGGING {
				if (ExternalInterface.available) {
					context.addLogTarget(new JSLogTarget());
				}
				Log.loggerFactory = new GrindLoggerFactory();
				injector.injectInto(Log.loggerFactory);
			}
			configuration();
		}
		
		protected function configuration():void {
			injector.map(PlayerConfiguration).asSingleton();
			injector.map(MediaPlayer).toSingleton(GrindMediaPlayerBase);
			injector.map(MediaResourceBase).toProvider(new ResourceProvider());
			injector.map(MediaFactory).toSingleton(GrindMediaFactoryBase);
			
			injector.map(ConfigurationProxy).toProvider(new ConfigurationProxyProvider());
			injector.map(ConfigurationFlashvarsDeserializer).toValue(
				new ConfigurationFlashvarsDeserializer(
					injector.getInstance(ConfigurationProxy)
				));
			injector.map(ConfigurationXMLDeserializer).toValue(
				new ConfigurationXMLDeserializer(
					injector.getInstance(ConfigurationProxy)
				));
			injector.map(ConfigurationLoader).toValue(
				new ConfigurationLoader(
					injector.getInstance(ConfigurationFlashvarsDeserializer),
					injector.getInstance(ConfigurationXMLDeserializer)
				));
		}
		
	}
	
}
