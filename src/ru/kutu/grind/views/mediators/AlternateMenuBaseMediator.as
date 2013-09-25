package ru.kutu.grind.views.mediators {
	
	import flash.events.Event;
	
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.AlternativeAudioTrait;
	import org.osmf.traits.MediaTraitType;
	
	import ru.kutu.grind.events.ControlBarMenuChangeEvent;
	import ru.kutu.grind.views.api.IAlternateMenuButton;
	import ru.kutu.grind.vos.LanguageSelectorVO;
	import ru.kutu.grind.vos.SelectorVO;
	
	public class AlternateMenuBaseMediator extends ControlBarMenuBaseMediator {
		
		protected static var DEFAULT_AUDIO_LABEL:String = "defaultAudioLabel";
		
		[Inject] public var view:IAlternateMenuButton;
		
		protected var alternateTrait:AlternativeAudioTrait;
		
		private var _requiredTraits:Vector.<String> = new <String>[MediaTraitType.ALTERNATIVE_AUDIO];
		
		override protected function get requiredTraits():Vector.<String> {
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void {
			alternateTrait = element.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait;
			if (alternateTrait) {
				alternateTrait.addEventListener(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, onNumStreamChange);
				alternateTrait.addEventListener(AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, onSwitchChange);
				onNumStreamChange();
				view.visible = true;
			}
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
			if (alternateTrait) {
				alternateTrait.removeEventListener(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, onNumStreamChange);
				alternateTrait.removeEventListener(AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, onSwitchChange);
				alternateTrait = null;
			}
			view.closeDropDown(false);
			view.visible = false;
		}
		
		override protected function onNumStreamChange(event:Event = null):void {
			if (!alternateTrait) return;
			
			var items:Array = new Array();
			
			var audioItem:StreamingItem;
			for (var i:uint = 0; i < alternateTrait.numAlternativeAudioStreams; ++i) {
				audioItem = alternateTrait.getItemForIndex(i);
				items.push({
					index: i
					, value: audioItem.info.label || audioItem.info.language
					, audioItem: audioItem
				});
			}
			
			items.sortOn("value", Array.CASEINSENSITIVE);
			
			selectors.length = 0;
			selectors.push(new LanguageSelectorVO(
				-1,
				media.resource.getMetadataValue(DEFAULT_AUDIO_LABEL) as String || "Default"
			));
			
			for each (var item:Object in items) {
				selectors.push(new LanguageSelectorVO(item.index, processLabelForSelectorVO(item), item.audioItem.info.language));
			}
			
			view.setSelectors(selectors);
			
			super.onNumStreamChange();
		}
		
		override protected function onSwitchChange(event:Event = null):void {
			if (!alternateTrait) return;
			
			var vo:SelectorVO = getSelectorVOByIndex(alternateTrait.currentIndex);
			if (vo) {
				view.selectedIndex = selectors.indexOf(vo);
			}
		}
		
		override protected function onMenuChange(event:ControlBarMenuChangeEvent):void {
			if (!alternateTrait) return;
			
			var vo:SelectorVO = selectors[view.selectedIndex];
			if (vo) {
				if (alternateTrait.currentIndex != vo.index) {
					alternateTrait.switchTo(vo.index);
					if (player.canSeek && player.canSeekTo(player.currentTime)) {
						player.seek(player.currentTime);
					}
				}
			}
		}
		
		override protected function processLabelForSelectorVO(item:Object):String {
			var audioItem:StreamingItem = item.audioItem as StreamingItem;
			return audioItem.info.label || audioItem.info.language;
		}
		
	}
	
}
