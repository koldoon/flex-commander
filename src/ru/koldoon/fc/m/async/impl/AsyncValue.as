package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.IAsyncValue;

    /**
     * Async Value Promise
     */
    public class AsyncValue extends Promise implements IAsyncValue {
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
