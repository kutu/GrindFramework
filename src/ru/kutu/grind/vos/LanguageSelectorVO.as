package ru.kutu.grind.vos {
	
	public class LanguageSelectorVO extends SelectorVO {
		
		public var language:String;
		
		public function LanguageSelectorVO(index:int=-1, label:String="Auto", language:String=null) {
			super(index, label);
			this.language = language;
		}
		
	}
	
}
