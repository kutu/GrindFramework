package ru.kutu.grind.config {

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.MulticastResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.configuration.ConfigurationProxy;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	public class ConfigurationProxyProvider implements DependencyProvider {

		public function apply(targetType:Class, activeInjector:Injector, injectParameters:Dictionary):Object {
			var configurationProxy:ConfigurationProxy = new ConfigurationProxy();
			var configuration:PlayerConfiguration = activeInjector.getInstance(PlayerConfiguration);
			var player:MediaPlayer = activeInjector.getInstance(MediaPlayer);

			var pcf:Dictionary = ConfigurationUtils.retrieveFields(getDefinitionByName(getQualifiedClassName(configuration)));
			configurationProxy.registerConfigurableProperties(pcf, configuration);

			var mpf:Dictionary = ConfigurationUtils.retrieveFields(getDefinitionByName(getQualifiedClassName(player)));
			configurationProxy.registerConfigurableProperties(mpf, player);

			var resourceFields:Dictionary = ConfigurationUtils.retrieveFields(MulticastResource);
			delete resourceFields["connectionArguments"];
			delete resourceFields["drmContentData"];
			configurationProxy.registerConfigurableProperties(resourceFields, configuration.resource);

			return configurationProxy;
		}

		public function destroy():void {
		}

	}

}
