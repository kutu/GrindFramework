package ru.kutu.grind.views.mediators  {

	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.configuration.ConfigurationLoader;
	import org.osmf.player.plugins.PluginLoader;
	import org.osmf.utils.OSMFSettings;
	import org.swiftsuspenders.Injector;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;
	
	import ru.kutu.grind.config.JavaScriptBridgeBase;
	import ru.kutu.grind.config.PlayerConfiguration;
	import ru.kutu.grind.events.LoadMediaEvent;
	import ru.kutu.grind.events.PlayerViewEvent;
	import ru.kutu.grind.views.api.IPlayerView;

	public class PlayerViewBaseMediator extends Mediator {

		[Inject] public var logger:ILogger;
		[Inject] public var injector:Injector;
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IPlayerView;
		[Inject] public var configuration:PlayerConfiguration;
		[Inject] public var player:MediaPlayer;
		[Inject] public var factory:MediaFactory;

		protected var mediaContainer:MediaContainer = new MediaContainer();

		override public function initialize():void {
			processConfiguration(contextView.view.stage.loaderInfo.parameters);
		}
		
		protected function processConfiguration(flashvars:Object):void {
			var configurationLoader:ConfigurationLoader = injector.getInstance(ConfigurationLoader);
			configurationLoader.addEventListener(Event.COMPLETE, onConfigurationReady);

			configurationLoader.load(flashvars, configuration);

			if (configuration.javascriptCallbackFunction != "" && ExternalInterface.available) {
				injector.getInstance(JavaScriptBridgeBase);
				addContextListener(LoadMediaEvent.LOAD_MEDIA, onLoadMedia, LoadMediaEvent);
			}
		}

		protected function onConfigurationReady(event:Event):void {
			OSMFSettings.enableStageVideo = configuration.enableStageVideo;

			// After initialization, either load the assigned media, or
			// load requested plug-ins first, and then load the assigned
			// media:
			var pluginConfigurations:Vector.<MediaResourceBase> = ConfigurationUtils.transformDynamicObjectToMediaResourceBases(configuration.plugins);
			var pluginResource:MediaResourceBase;
			
			addCustomPlugins(pluginConfigurations);

			// EXPERIMENTAL: Ad plugin integration
			for each(pluginResource in pluginConfigurations) {
				pluginResource.addMetadataValue("MediaContainer", mediaContainer);
				pluginResource.addMetadataValue("MediaPlayer", player);
			}

			var pluginLoader:PluginLoader;
			pluginLoader = new PluginLoader(pluginConfigurations, factory, null);
			pluginLoader.haltOnError = configuration.haltOnError;
			pluginLoader.addEventListener(Event.COMPLETE, onPluginLoaded);
			pluginLoader.loadPlugins();
		}
		
		protected function addCustomPlugins(pluginConfigurations:Vector.<MediaResourceBase>):void {
		}
		
		protected function onPluginLoaded(event:Event):void {
			initializeView();
			loadMedia();
		}

		protected function initializeView():void {
			mediaContainer.clipChildren = true;
			mediaContainer.layoutMetadata.percentWidth = 100;
			mediaContainer.layoutMetadata.percentHeight = 100;
			view.mediaPlayerContainer.addChild(mediaContainer);

			addViewListener(PlayerViewEvent.RESIZE, onViewResize, PlayerViewEvent);
			onViewResize();
		}

		protected function loadMedia():void {
			var resource:MediaResourceBase = injector.getInstance(MediaResourceBase);
			var oldMedia:MediaElement = player.media;
			var media:MediaElement = factory.createMediaElement(resource);

			if (!media) {
				CONFIG::LOGGING {
					logger.error("Media is null");
				}
				return;
			}

			var layoutMetadata:LayoutMetadata = media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
			if (!layoutMetadata) {
				layoutMetadata = new LayoutMetadata();
				media.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
			}
			layoutMetadata.scaleMode = configuration.scaleMode;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.percentWidth = 100;
			layoutMetadata.percentHeight = 100;
			layoutMetadata.index = 1;

			if (player.media && mediaContainer.containsMediaElement(player.media)) {
				mediaContainer.removeMediaElement(player.media);
			}
			mediaContainer.addMediaElement(media);
			player.media = media;
		}

		protected function onViewResize(event:Event = null):void {
			if (mediaContainer) {
				mediaContainer.width = view.mediaPlayerContainer.width;
				mediaContainer.height = view.mediaPlayerContainer.height;
			}
		}

		protected function onLoadMedia(event:LoadMediaEvent):void {
			loadMedia();
		}

	}

}
