package org.flexlayouts.layouts {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class RectangleLayout extends LayoutBase {
		private var _horizontalGap:Number = 6;
		private var _verticalGap:Number = 6;
		private var _rotateElements:Boolean = false;
		
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
		
		public function set rotateElements(val:Boolean):void {
			_rotateElements = val;
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
			var firstHeight:Number = 0;
			var prevWidth:Number = 0;
			var prevHeight:Number = 0;
			var side:int = 0; //0=top, 1=right, 2=bottom, 3=left
			var tmp:Number;
			
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			var element:ILayoutElement;
			
			//loop through all the elements
			for (var i:int = 0; i < count; i++) {
				element = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );
				
				//remove any rotations
				element.setLayoutMatrix3D(new Matrix3D(), false);
				
				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);
				
				//get element's size, but AFTER it has been resized to its preferred size.
				var elementWidth:Number = Math.floor(element.getLayoutBoundsWidth());
				var elementHeight:Number = Math.floor(element.getLayoutBoundsHeight());
				
				//if rotating, swap width & height
				if (_rotateElements && (side == 1 || side == 3)) {
					tmp = elementWidth;
					elementWidth = elementHeight;
					elementHeight = tmp;
				}
				
				//store the height of the 1st element so we can use it later
				if (i == 0) {
					firstHeight = elementHeight;
				}
				
				//round pos
				x = Math.floor(x);
				y = Math.floor(y);
				
				//does the element fit, or should we move to the next side?
				if (side == 0 && x + elementWidth > containerWidth) {
					if (i == 0) {
						//handle special case of first element
						x = 0;
					} else {
						//element does not fit on top, so move down right side
						x = containerWidth;
						y = prevHeight + _verticalGap;
						side = 1;
						
						//swap
						if (_rotateElements) {
							tmp = elementWidth;
							elementWidth = elementHeight;
							elementHeight = tmp;
						}
					}
				} else if (side == 1 && y + elementHeight > containerHeight) {
					//element does not fit on right side, so move to bottom
					x = containerWidth - prevWidth - _horizontalGap;
					y = containerHeight;
					side = 2;
					
					//swap back
					if (_rotateElements) {
						tmp = elementWidth;
						elementWidth = elementHeight;
						elementHeight = tmp;
					}
				} else if (side == 2 && x - elementWidth < 0) {
					//element does not fit on bottom, so move to left side
					x = 0;
					y = containerHeight - prevHeight - _verticalGap;
					side = 3;
					
					//swap
					if (_rotateElements) {
						tmp = elementWidth;
						elementWidth = elementHeight;
						elementHeight = tmp;
					}
				} else if (side == 3 && y - elementHeight < firstHeight) {
					//element does not fit on left side, so skip it
					x = 0;
					y = 0;
					side = 4;
				}
				
				if (side == 0) {
					//pass
				} else if (side == 1) {
					x -= elementWidth;
				} else if (side == 2) {
					x -= elementWidth;
					y -= elementHeight;
				} else if (side == 3) {
					y -= elementHeight;
				}
				
				//rotate the element
				var mat:Matrix3D = new Matrix3D();
				if (_rotateElements) {
					if (side == 0) {
						mat.appendTranslation(-elementWidth * 0.5, -elementHeight * 0.5, 0);
						mat.appendRotation(180, Vector3D.Z_AXIS);
						mat.appendTranslation(elementWidth * 0.5, elementHeight * 0.5, 0);
					} else if (side == 1) {
						mat.appendRotation(-90, Vector3D.Z_AXIS);
						mat.appendTranslation(elementHeight - elementWidth, elementHeight, 0);
					} else if (side == 2) {
						//pass
					} else if (side == 3) {
						mat.appendTranslation(-elementHeight * 0.5, -elementWidth * 0.5, 0);
						mat.appendRotation(90, Vector3D.Z_AXIS);
						mat.appendTranslation(elementHeight * 0.5, elementWidth * 0.5, 0);
					}
				}
				element.setLayoutMatrix3D(mat, false);
				
				//position the element
				if (side < 4) {
					element.setLayoutBoundsPosition(x, y);
					
					//update max dimensions (needed for scrolling)
					maxWidth = Math.max(maxWidth, x + elementWidth);
					maxHeight = Math.max(maxHeight, y + elementHeight);
					
					//make sure element is visible
					(element as IVisualElement).visible = true;
				} else {
					//hide all overflow
					(element as IVisualElement).visible = false;
				}
				
				//update the current pos, and add the gap
				if (side == 0) {
					x += elementWidth + _horizontalGap;
					y = 0;
				} else if (side == 1) {
					x = containerWidth;
					y += elementHeight + _verticalGap;
				} else if (side == 2) {
					x -= _horizontalGap;
					y = containerHeight;
				} else if (side == 3) {
					x = 0;
					y -= _verticalGap;
				}
				
				prevWidth = elementWidth;
				prevHeight = elementHeight;
			}
			
			//set final content size (needed for scrolling)
			layoutTarget.setContentSize(maxWidth, maxHeight);
		}
	}
}