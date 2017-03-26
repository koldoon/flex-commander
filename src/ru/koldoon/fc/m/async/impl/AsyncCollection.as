package ru.koldoon.fc.m.async.impl {
    import mx.collections.IList;

    import ru.koldoon.fc.m.async.IAsyncCollection;

    /**
     * Async Collection Promise
     */
    public class AsyncCollection extends Promise implements IAsyncCollection {
        public function AsyncCollection() {
            items_ = [];
        }


        public function get items():Array {
            return items_;
        }


        public function applyResult(data:* = null):void {
            if (data is Array) {
                items_ = data;
            }
            else if (data is IList) {
                items_ = IList(data).toArray();
            }
            ready();
        }


        private var items_:Array;
    }
}
