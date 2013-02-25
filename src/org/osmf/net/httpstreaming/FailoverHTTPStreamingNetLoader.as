/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.httpstreaming
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.dvr.FailoverHTTPStreamingDVRCastDVRTrait;
	import org.osmf.net.httpstreaming.dvr.FailoverHTTPStreamingDVRCastTimeTrait;
	import org.osmf.traits.LoadState;

	/**
	 * HTTPStreamingNetLoader is a NetLoader that can load HTTP streams.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class FailoverHTTPStreamingNetLoader extends HTTPStreamingNetLoader
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function FailoverHTTPStreamingNetLoader()
		{
			// Connection sharing and custom NetConnectionFactory classes are
			// irrelevant for HTTP streaming connections, hence we don't allow
			// the client to pass those params in.
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var factory:HTTPStreamingFactory = createHTTPStreamingFactory();
			var httpNetStream:FailoverHTTPNetStream = new FailoverHTTPNetStream(connection, factory, resource);
			return httpNetStream;
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override protected function processFinishLoading(loadTrait:NetStreamLoadTrait):void
		{
			var resource:URLResource = loadTrait.resource as URLResource;
			
			if (!dvrMetadataPresent(resource))
			{
				updateLoadTrait(loadTrait, LoadState.READY);
				
				return;
			}

			var netStream:FailoverHTTPNetStream = loadTrait.netStream as FailoverHTTPNetStream;
			netStream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			netStream.DVRGetStreamInfo(null);
			function onDVRStreamInfo(event:DVRStreamInfoEvent):void
			{
				netStream.removeEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
				
				loadTrait.setTrait(new FailoverHTTPStreamingDVRCastDVRTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				loadTrait.setTrait(new FailoverHTTPStreamingDVRCastTimeTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				updateLoadTrait(loadTrait, LoadState.READY);
			}
		}
		
		//
		// Internal
		//

		private function dvrMetadataPresent(resource:URLResource):Boolean
		{
			var metadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
			
			return (metadata != null);
		}
		
	}
	
}
