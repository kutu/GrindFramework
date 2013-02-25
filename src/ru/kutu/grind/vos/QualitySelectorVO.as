package ru.kutu.grind.vos {
	
	public class QualitySelectorVO extends SelectorVO {
		
		public var bitrate:Number;
		public var height:int;
		
		public function QualitySelectorVO(index:int=-1, label:String="Auto", bitrate:Number=NaN, height:int=-1) {
			super(index, label);
			this.bitrate = bitrate;
			this.height = height;
		}
		
	}
	
}
