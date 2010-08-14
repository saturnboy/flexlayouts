package org.flexlayouts.utils {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class Randomizer extends EventDispatcher {
		private var _random:ArrayCollection;
		private var _min:int = 0;
		private var _max:int = 0;
		private var _len:int = 0;

		public function Randomizer(min:int = 0, max:int = 100, len:int = 100) {
			_min = min;
			_max = max;
			_len = len;
			refresh();
		}

		[Bindable(event="dataChange")]
		public function getList(len:int = -1):ArrayCollection {
			if (len == -1) return _random;
			if (len < 0) throw new Error('len must be positive');
			if (len > _len) throw new Error('len bigger than list size');
			return new ArrayCollection(_random.toArray().slice(0,len));
		}

		[Bindable(event="dataChange")]
		public function getItem(index:int = 0):int {
			if (index < 0) throw new Error('index must be positive');
			if (index >= _len) throw new Error('index bigger than list size');
			return _random[index];
		}

		public function refresh():void {
			var a:Array = [];
			var d:int = _max - _min
			for (var i:int = 0; i < _len; i++) {
				var j:int = int(Math.round(Math.random() * d + _min));
				a.push(j);
			}
			_random = new ArrayCollection(a);
			dispatchEvent(new Event('dataChange'));
		}

		public function set min(val:int):void {
			if (_min != val) {
				if (val < 0) throw new Error('min must be positive');
				if (val > _max) throw new Error('min must be less than max');
				_min = val;
				refresh();
			}
		}

		public function set max(val:int):void {
			if (_max != val) {
				if (val < _min) throw new Error('max must be greater than min');
				_max = val;
				refresh();
			}
		}
	}
}