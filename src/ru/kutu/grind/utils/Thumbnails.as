package ru.kutu.grind.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class Thumbnails extends Sprite {
		
		public static const NAMESPACE:String = "thumbnails";
		
		protected static const ZERO_POINT:Point = new Point();
		
		protected var thumbnail:Bitmap;
		protected var req:URLRequest;
		protected var context:LoaderContext;
		protected var thumbnailsLoader:Loader;
		protected var thumbnailsImage:BitmapData;
		protected var loadAttempts:uint;
		
		protected var totalImages:int;
		protected var prevIndex:int;
		
		public function Thumbnails() {
			context = new LoaderContext(true, ApplicationDomain.currentDomain);
		}
		
		public function setup(url:String, w:uint, h:uint, total:uint):void {
			totalImages = -1;
			prevIndex = -1;
			loadAttempts = 3;
			
			if (thumbnail) {
				removeChild(thumbnail);
				thumbnail.bitmapData.dispose();
				thumbnail = null;
			}
			
			thumbnail = new Bitmap(new BitmapData(w, h));
			thumbnail.smoothing = true;
			totalImages = total;
			addChild(thumbnail);
			
			if (!thumbnailsLoader) {
				thumbnailsLoader = new Loader();
				thumbnailsLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbnailsLoaded);
				thumbnailsLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onThumbnailsError);
			}
			req = new URLRequest(url);
			
			loadThumnails();
		}
		
		public function update(time:Number, duration:Number):void {
			if (!thumbnail || !thumbnailsImage) return;
			
			var index:uint = time / duration * totalImages;
			index = Math.min(index, totalImages - 1);
			if (index == prevIndex) return;
			prevIndex = index;
			
			var w:uint = thumbnail.bitmapData.width;
			var h:uint = thumbnail.bitmapData.height;
			var widthCount:uint = thumbnailsImage.width / w;
			var xIndex:uint = index % widthCount;
			var yIndex:uint = index / widthCount;
			var rect:Rectangle = new Rectangle(xIndex * w, yIndex * h, w, h);
			thumbnail.bitmapData.copyPixels(thumbnailsImage, rect, ZERO_POINT);
		}
		
		protected function loadThumnails():void {
			if (!req) return;
			try {
				thumbnailsLoader.close();
			} catch(error:Error) {}
			thumbnailsLoader.load(req, context);
		}
		
		protected function onThumbnailsLoaded(event:Event):void {
			thumbnailsLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onThumbnailsLoaded);
			thumbnailsLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onThumbnailsError);
			thumbnailsImage = (thumbnailsLoader.content as Bitmap).bitmapData.clone();
			thumbnailsLoader.unload();
			thumbnailsLoader = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onThumbnailsError(event:IOErrorEvent):void {
			if (--loadAttempts) {
				loadThumnails();
			}
		}
		
	}
	
}
