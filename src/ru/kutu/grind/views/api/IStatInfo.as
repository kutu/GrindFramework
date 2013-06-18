package ru.kutu.grind.views.api {
	
	import flash.net.NetStream;
	
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.net.qos.QoSInfo;
	
	import ru.kutu.grind.views.api.helpers.IVisible;
	
	public interface IStatInfo extends IVisible {
		
		function clear():void;
		function update(videoSurface:VideoSurface, netStream:NetStream, qosInfos:Vector.<QoSInfo>):void;
		
	}
	
}
