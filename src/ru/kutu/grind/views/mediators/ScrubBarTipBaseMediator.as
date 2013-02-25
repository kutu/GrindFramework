package ru.kutu.grind.views.mediators {
	
	import by.blooddy.crypto.serialization.JSON;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.osmf.media.MediaElement;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	
	import ru.kutu.grind.events.AutoHideEvent;
	import ru.kutu.grind.events.ScrubBarEvent;
	import ru.kutu.grind.events.ScrubBarTipEvent;
	import ru.kutu.grind.utils.Thumbnails;
	import ru.kutu.grind.views.api.IScrubBar;
	import ru.kutu.grind.views.api.IScrubBarTip;
	
	public class ScrubBarTipBaseMediator extends MediaControlBaseMediator {
		
		[Inject] public var contextView:ContextView;
		[Inject] public var view:IScrubBarTip;
		[Inject] public var scrubBar:IScrubBar;
		
		private var thumbnails:Thumbnails;
		
		private var isMouseOverTrack:Boolean;
		private var mouseMovePending:Boolean;
		private var mostRecentTrackPoint:Point = new Point();
		
		private var isTipVisible:Boolean;
		private var hasThumbnails:Boolean;
		
		override public function initialize():void {
			super.initialize();
			scrubBar.addEventListener(ScrubBarEvent.SHOW_TIP, onShowTip);
			scrubBar.addEventListener(ScrubBarEvent.HIDE_TIP, onHideTip);
			scrubBar.addEventListener(ScrubBarEvent.HIDE_TIP_IMMEDIATE, onHideTip);
			scrubBar.addEventListener(ScrubBarTipEvent.TIP_DATA_UPDATE, onDataUpdate);
			addContextListener(AutoHideEvent.HIDE, onAutoHide, AutoHideEvent);
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
			if (oldMediaElement) {
				if (thumbnails && view.thumbnailsContainer.contains(thumbnails)) {
					view.thumbnailsContainer.removeChild(thumbnails);
				}
				hasThumbnails = false;
				updateState();
			}
			
			var thumbnailsJson:String = media.resource.getMetadataValue(Thumbnails.NAMESPACE) as String;
			if (thumbnailsJson) {
				try {
					var data:Object = JSON.decode(thumbnailsJson);
				} catch(error:Error) {}
			}
			
			if (data && data.url) {
				if (!thumbnails) {
					thumbnails = new Thumbnails();
					thumbnails.addEventListener(Event.COMPLETE, onThumbnailsComplete);
				}
				const w:Number = data.width;
				const h:Number = data.height;
				const t:Number = data.total;
				if (!isNaN(w) && w > 0 && !isNaN(h) && h > 0 && !isNaN(t) && t > 0) {
					thumbnails.setup(data.url, w, h, t);
				}
			}
		}
		
		protected function onShowTip(event:ScrubBarEvent):void {
			isTipVisible = true;
			updateState();
		}
		
		protected function onHideTip(event:ScrubBarEvent):void {
			isTipVisible = false;
			updateState(event.type == ScrubBarEvent.HIDE_TIP);
		}
		
		protected function onDataUpdate(event:ScrubBarTipEvent):void {
			view.data = event.time;
			view.updatePosition(event.globalPoint);
			if (thumbnails) {
				thumbnails.update(event.time, player.duration);
			}
		}
		
		protected function onThumbnailsComplete(event:Event):void {
			view.thumbnailsContainer.addChild(thumbnails);
			view.thumbnailsContainer.width = thumbnails.width;
			view.thumbnailsContainer.height = thumbnails.height;
			hasThumbnails = true;
			updateState();
			thumbnails.update(Number(view.data), player.duration);
		}
		
		protected function onAutoHide(event:AutoHideEvent):void {
			scrubBar.hideTip();
		}
		
		protected function updateState(playTransition:Boolean = true):void {
			if (isTipVisible) {
				view.normal(hasThumbnails, playTransition);
			} else {
				view.hidden(hasThumbnails, playTransition);
			}
		}
		
	}
	
}
