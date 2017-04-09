package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.IValuePromise;

    /**
     * Async Value Promise
     */
    public class ValuePromise extends Promise implements IValuePromise {
        private var _value:*;

        public function get value():* {
            return _value;
        }

        public function applyResult(data:* = null):void {
            _value = data;
            ready();
        }
    }
}
