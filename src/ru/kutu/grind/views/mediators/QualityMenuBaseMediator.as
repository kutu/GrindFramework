package ru.kutu.grind.views.mediators {
	
	import flash.events.Event;
	
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitType;
	
	import ru.kutu.grind.config.LocalSettings;
	import ru.kutu.grind.events.ControlBarMenuChangeEvent;
	import ru.kutu.grind.views.api.IQualityMenuButton;
	import ru.kutu.grind.vos.QualitySelectorVO;
	import ru.kutu.grind.vos.SelectorVO;
	
	public class QualityMenuBaseMediator extends ControlBarMenuBaseMediator {
		
		[Inject] public var view:IQualityMenuButton;
		[Inject] public var ls:LocalSettings;
		
		protected var dynamicTrait:DynamicStreamTrait;
		protected var streamItems:Vector.<DynamicStreamingItem>;
		
		private var _requiredTraits:Vector.<String> = new <String>[MediaTraitType.DYNAMIC_STREAM];
		
		override protected function get requiredTraits():Vector.<String> {
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void {
			dynamicTrait = element.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
			if (dynamicTrait) {
				dynamicTrait.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, onNumStreamChange);
				dynamicTrait.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onSwitchChange);
				dynamicTrait.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchChange);
				onNumStreamChange();
				view.visible = true;
			}
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
			if (dynamicTrait) {
				dynamicTrait.removeEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, onNumStreamChange);
				dynamicTrait.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onSwitchChange);
				dynamicTrait.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchChange);
				dynamicTrait = null;
			}
			view.closeDropDown(false);
			view.visible = false;
		}
		
		override protected function onNumStreamChange(event:Event = null):void {
			if (!media) return;
			
			var dynamicResource:DynamicStreamingResource = MediaElementUtils.getResourceFromParentOfType(media, DynamicStreamingResource) as DynamicStreamingResource;
			streamItems = dynamicResource.streamItems;
			
			// extract bitrate and height
			var items:Array = new Array();
			var index:uint, value:Number;
			var dynamicItem:DynamicStreamingItem;
			for each (dynamicItem in streamItems) {
				value = dynamicItem.height > 0 ? dynamicItem.height :
					dynamicItem.bitrate > 0 ? dynamicItem.bitrate :
					0;
				items.push({
					index: index++
					, height: dynamicItem.height
					, bitrate: dynamicItem.bitrate
					, dynamicItem: dynamicItem
				});
			}
			
			items.sortOn(["height", "bitrate"], Array.DESCENDING | Array.NUMERIC);
			
			selectors.length = 0;
			selectors.push(new QualitySelectorVO());
			
			for each (var item:Object in items) {
				selectors.push(new QualitySelectorVO(item.index, processLabelForSelectorVO(item), item.bitrate, item.height));
			}
			
			view.setSelectors(selectors);
			
			selectInitialIndex();
			
			super.onNumStreamChange();
			
			if (!player.autoDynamicStreamSwitch) {
				var vo:SelectorVO = getSelectorVOByIndex(dynamicResource.initialIndex);
				if (vo) {
					view.selectedIndex = selectors.indexOf(vo);
				}
			}
		}
		
		override protected function onSwitchChange(event:Event = null):void {
			if (!dynamicTrait) return;
			if (event && event is DynamicStreamEvent && (event as DynamicStreamEvent).switching) return;
			
			if (dynamicTrait.autoSwitch) {
				view.selectedIndex = 0;
			} else {
				var vo:SelectorVO = getSelectorVOByIndex(dynamicTrait.currentIndex);
				if (vo) {
					view.selectedIndex = selectors.indexOf(vo);
				}
			}
			
			view.currentIndex = dynamicTrait.currentIndex;
			
			ls.qualityAutoSwitch = dynamicTrait.autoSwitch;
			if (streamItems[dynamicTrait.currentIndex].bitrate > 0) {
				ls.qualityPreferBitrate = streamItems[dynamicTrait.currentIndex].bitrate;
			}
			if (streamItems[dynamicTrait.currentIndex].height > 0) {
				ls.qualityPreferHeight = streamItems[dynamicTrait.currentIndex].height;
			}
		}
		
		override protected function onMenuChange(event:ControlBarMenuChangeEvent):void {
			if (!dynamicTrait) return;
			
			var vo:SelectorVO = selectors[view.selectedIndex];
			if (vo) {
				if (vo.index == -1) {
					// auto
					dynamicTrait.autoSwitch = true;
				} else {
					// manual
					dynamicTrait.autoSwitch = false;
					if (dynamicTrait.currentIndex != vo.index) {
						dynamicTrait.switchTo(vo.index);
						if (player.canSeek && player.canSeekTo(player.currentTime)) {
							player.seek(player.currentTime);
						}
					}
				}
			}
		}
		
		override protected function processLabelForSelectorVO(item:Object):String {
			var dynamicItem:DynamicStreamingItem = item.dynamicItem;
			if (dynamicItem) {
				var res:Array = [];
				if (dynamicItem.height > 0) {
					res.push(dynamicItem.height + "p");
				}
				if (dynamicItem.bitrate > 0) {
					res.push(Math.round(dynamicItem.bitrate) + "kbps");
				}
				if (res.length) {
					return res.join(" ");
				}
			}
			return "none";
		}
		
		protected function selectInitialIndex():void {
			var dynamicResource:DynamicStreamingResource = MediaElementUtils.getResourceFromParentOfType(media, DynamicStreamingResource) as DynamicStreamingResource;
			var dynamicItem:DynamicStreamingItem;
			
			// find prefer height
			var preferHeight:int = ls.qualityPreferHeight;
			var preferIndex:int = -1;
			if (preferHeight > 0) {
				var minDiffHeight:int = int.MAX_VALUE;
				for each (dynamicItem in streamItems) {
					var h:int = dynamicItem.height;
					if (h <= 0) {
						preferIndex = -1;
						break;
					}
					if (Math.abs(preferHeight - h) < minDiffHeight) {
						minDiffHeight = Math.abs(preferHeight - h);
						preferIndex = streamItems.indexOf(dynamicItem);
					}
				}
			}
			
			// if not have prefer height
			if (preferIndex == -1) {
				// find prefer bitrate
				var preferBitrate:Number = ls.qualityPreferBitrate;
				if (!isNaN(preferBitrate) && preferBitrate > 0) {
					var minDiffBitrate:Number = Number.MAX_VALUE;
					for each (dynamicItem in streamItems) {
						var br:Number = dynamicItem.bitrate;
						if (br <= 0) {
							preferIndex = -1;
							break;
						}
						if (Math.abs(preferBitrate - br) < minDiffBitrate) {
							minDiffBitrate = Math.abs(preferBitrate - br);
							preferIndex = streamItems.indexOf(dynamicItem);
						}
					}
				}
			}
			
			// switch to prefer index and set autoSwitch mode
			var autoSwitch:Boolean = ls.qualityAutoSwitch;
			if (preferIndex != -1 && preferIndex != dynamicResource.initialIndex) {
				dynamicResource.initialIndex = preferIndex;
				player.autoDynamicStreamSwitch = false;
				player.switchDynamicStreamIndex(preferIndex);
			}
			player.autoDynamicStreamSwitch = autoSwitch;
		}
		
	}
	
}
