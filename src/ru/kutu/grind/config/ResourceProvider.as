package ru.kutu.grind.config {
	
	import flash.utils.Dictionary;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.MulticastResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	
	public class ResourceProvider implements DependencyProvider {
		
		public function apply(targetType:Class, activeInjector:Injector, injectParameters:Dictionary):Object {
			var configuration:PlayerConfiguration = activeInjector.getInstance(PlayerConfiguration);
			var resource:MediaResourceBase;
			
			if (configuration.resource.hasOwnProperty("groupspec")) {
				resource = new MulticastResource(configuration.src);
				
				if (configuration.resource.hasOwnProperty("multicastStreamName")) {
					// The public f4m config value and the API name of the multicastStreamName do not match
					(resource as MulticastResource).streamName = configuration.resource.multicastStreamName;
				}
			} else {
				resource = new StreamingURLResource(configuration.src);
			}
			for (var name:String in configuration.resource) {
				var value:Object = configuration.resource[name];
				resource[name] = value;
			}
			// Add the configuration metadata to the resource.
			// Transform the Object to Metadata instance.
			ConfigurationUtils.addMetadataToResource(configuration.metadata, resource);
			return resource;
		}
		
		public function destroy():void {
		}
		
	}
	
}
