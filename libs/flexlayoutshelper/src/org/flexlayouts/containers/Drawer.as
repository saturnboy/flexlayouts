package org.flexlayouts.containers {
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;

	[SkinState("opened")]
	public class Drawer extends SkinnableContainer {
		[SkinPart(required="false")]
		public var openButton:Button;

		private var _opened:Boolean = false;

		public function get opened():Boolean {
			return _opened;
		}

		public function set opened(value:Boolean):void {
			if (_opened != value) {
				_opened = value;
				invalidateSkinState();
			}
		}

		private function openHandler(e:MouseEvent):void {
			opened = !opened;
		}

		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == openButton) {
				openButton.addEventListener(MouseEvent.CLICK, openHandler);
			}
		}

		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			if (instance == openButton) {
				openButton.removeEventListener(MouseEvent.CLICK, openHandler);
			}
		}

		override protected function getCurrentSkinState():String {
			return (opened ? 'opened' : super.getCurrentSkinState());
		}
	}
}