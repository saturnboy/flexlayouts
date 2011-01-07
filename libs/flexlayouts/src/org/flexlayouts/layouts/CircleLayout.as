package org.flexlayouts.layouts {
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;

	public class CircleLayout extends LayoutBase {
		private static const TWO_PI:Number = Math.PI * 2.0;
		private static const PI_OVER_180:Number = Math.PI / 180.0;

		private var _rotation:Number = 0;

		public function set rotation(val:Number):void {
			_rotation = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}

		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void {
			var x:Number = 0;
			var y:Number = 0;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var contentWidth:Number = 0;
			var contentHeight:Number = 0;
			var radius:Number = 0;
			var theta:Number = 0;
			var element:ILayoutElement;
			var elementWidth:Number;
			var elementHeight:Number

			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;

			//first compute the max width & max height of all the elementa
			for (var i:int = 0; i < count; i++) {
				element = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );

				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);

				//get element's size, but AFTER it has been resized to its preferred size.
				elementWidth = element.getLayoutBoundsWidth();
				elementHeight = element.getLayoutBoundsHeight();

				if (elementWidth > maxWidth) { maxWidth = elementWidth; }
				if (elementHeight > maxHeight) { maxHeight = elementHeight; }
			}

			//we want the entire circle of elements to fit within the container,
			//so we must find the limiting dimension and compute radius from that
			if (containerWidth - maxWidth > containerHeight - maxHeight) {
				radius = 0.5 * (containerHeight - maxHeight);
			} else {
				radius = 0.5 * (containerWidth - maxWidth);
			}

			//next, layout the elements in a circle
			for (var j:int = 0; j < count; j++) {
				element = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(j) : layoutTarget.getElementAt(j) );

				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);

				//get element's size, but AFTER it has been resized to its preferred size.
				elementWidth = element.getLayoutBoundsWidth();
				elementHeight = element.getLayoutBoundsHeight();

				//compute angle, plus any extra rotation
				theta = j / count * TWO_PI + _rotation * PI_OVER_180;

				//set element position around the circle
				x = radius * Math.cos(theta) + 0.5 * (containerWidth - elementWidth);
				y = radius * Math.sin(theta) + 0.5 * (containerHeight - elementHeight);
				element.setLayoutBoundsPosition(x, y);
			}
		}
	}
}
