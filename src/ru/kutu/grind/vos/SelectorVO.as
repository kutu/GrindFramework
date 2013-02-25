package ru.kutu.grind.vos {
	
	public class SelectorVO {
		
		public var index:int;
		public var label:String;
		public var isCurrent:Boolean;
		
		public function SelectorVO(index:int = -1, label:String = "Auto") {
			this.index = index;
			this.label = label;
		}
		
	}
	
}
