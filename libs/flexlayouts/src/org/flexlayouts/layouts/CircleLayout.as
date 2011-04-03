package org.flexlayouts.layouts {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class CircleLayout extends LayoutBase {
		private static const TWO_PI:Number = Math.PI * 2.0;
		private static const PI_OVER_180:Number = Math.PI / 180.0;
		
		private var _rotation:Number = 0;
		private var _rotateElements:Boolean = false;
		
		public function set rotation(val:Number):void {
			_rotation = val;
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
			var contentWidth:Number = 0;
			var contentHeight:Number = 0;
			var radius:Number = 0;
			var theta:Number = 0;
			var element:ILayoutElement;
			var elementWidth:Number;
			var elementHeight:Number
			
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			
			//first compute the max width & max height of all the elements
			for (var i:int = 0; i < count; i++) {
				element = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );
				
				//remove any rotations
				element.setLayoutMatrix3D(new Matrix3D(), false);
				
				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);
				
				//get element's size, but AFTER it has been resized to its preferred size
				elementWidth = element.getLayoutBoundsWidth();
				elementHeight = element.getLayoutBoundsHeight();
				
				if (elementWidth > maxWidth) { maxWidth = elementWidth; }
				if (elementHeight > maxHeight) { maxHeight = elementHeight; }
			}
			
			//we want the entire circle of elements to fit within the container,
			//so we must find the limiting dimension and compute radius from that
			//NOTE: watch out for element rotation: use maxHeight instead of maxWidth
			var maxWidthRotated:Number = (_rotateElements ? maxHeight : maxWidth);
			if (containerWidth - maxWidthRotated > containerHeight - maxHeight) {
				radius = 0.5 * (containerHeight - maxHeight);
			} else {
				radius = 0.5 * (containerWidth - maxWidthRotated);
			}
			
			//next, layout the elements in a circle
			for (var j:int = 0; j < count; j++) {
				element = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(j) : layoutTarget.getElementAt(j) );
				
				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);
				
				//compute angle, plus any extra rotation
				theta = j / count * TWO_PI + _rotation * PI_OVER_180;
				
				//rotate the element if necessary
				if (_rotateElements) {
					var mat:Matrix3D = new Matrix3D();
					mat.appendRotation(theta / PI_OVER_180 + 90, Vector3D.Z_AXIS);
					element.setLayoutMatrix3D(mat, false);
				}
				
				//get element's size, but after rotation has been applied
				elementWidth = element.getLayoutBoundsWidth();
				elementHeight = element.getLayoutBoundsHeight();
				
				//set element position (acutally the element's bounding box position) along the circle
				x = Math.round(radius * Math.cos(theta) + 0.5 * (containerWidth - elementWidth));
				y = Math.round(radius * Math.sin(theta) + 0.5 * (containerHeight - elementHeight));
				
				element.setLayoutBoundsPosition(x, y);
			}
		}
	}
}