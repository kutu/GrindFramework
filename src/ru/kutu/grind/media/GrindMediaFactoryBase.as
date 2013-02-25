package ru.kutu.grind.media {

	import org.osmf.elements.F4MElement;
	import org.osmf.elements.FailoverF4MLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.net.httpstreaming.FailoverHTTPStreamingNetLoader;

	public class GrindMediaFactoryBase extends DefaultMediaFactory {

		public function GrindMediaFactoryBase() {
			super();
			
			// replace with failover f4mloader
			var f4mLoader:FailoverF4MLoader = new FailoverF4MLoader(this);
				addItem
				( new MediaFactoryItem
					( "org.osmf.elements.f4m"
						, f4mLoader.canHandleResource
						, function():MediaElement
						{
							return new F4MElement(null, f4mLoader);
						}
					)
				);
			
			CONFIG::FLASH_10_1 {
				// replace with failover httpstreaming
				var httpStreamingNetLoader:FailoverHTTPStreamingNetLoader = new FailoverHTTPStreamingNetLoader();
				addItem
					( new MediaFactoryItem
						( "org.osmf.elements.video.httpstreaming"
							, httpStreamingNetLoader.canHandleResource
							, function():MediaElement
							{
								return new VideoElement(null, httpStreamingNetLoader);
							}
						)
					);
			}
		}

	}

}
