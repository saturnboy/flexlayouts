package org.flexlayouts.layouts {
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;

	/**
	 * Similar to FlowLayout, but items flop direction and starting point with
	 * each successive row.  The first row is left-to-right starting at the left
	 * edge of the container, the second row is right-to-left starting at the
	 * right edge, and so on.
	 */
	public class SnakeLayout extends LayoutBase {
		private var _horizontalGap:Number = 6;
		private var _verticalGap:Number = 6;

		public function set horizontalGap(val:Number):void {
			_horizontalGap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}

		public function set verticalGap(val:Number):void {
			_verticalGap = val;
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

			//loop through all the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			var row:int = 0;

			for (var i:int = 0; i < count; i++) {
				var element:ILayoutElement = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );

				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);

				//get element's size, but AFTER it has been resized to its preferred size.
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();

				//does the element fit on this line, or should we move to the next line?
				if (row % 2 == 0 && x + elementWidth > containerWidth) {
					//going from odd row to even row, so start from the right side
					x = containerWidth;

					//move to the next line, and add the gap, but not if it's the first element
					if (i > 0) {
						y += elementHeight + _verticalGap;
						row++;
					}
				} else if (row % 2 != 0 && x - elementWidth < 0) {
					//going from even row to odd row, so start from the left side
					x = 0;

					//move to the next line, and add the gap, but not if it's the first element
					if (i > 0) {
						y += elementHeight + _verticalGap;
						row++;
					}
				}
				
				//position the element
				if (row % 2 == 0) {
					//update max dimensions (needed for scrolling)
					maxWidth = Math.max(maxWidth, x + elementWidth);
					maxHeight = Math.max(maxHeight, y + elementHeight);
				} else {
					x -= elementWidth;
				}

				element.setLayoutBoundsPosition(x, y);


				//update the current pos, and add the gap
				if (row % 2 == 0) {
					x += elementWidth + _horizontalGap;
				} else {
					x -= _horizontalGap;
				}
			}

			//set final content size (needed for scrolling)
			layoutTarget.setContentSize(maxWidth, maxHeight);
		}
	}
}