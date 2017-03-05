package ru.koldoon.fc.m.async.impl {
    import mx.collections.ArrayCollection;

    import ru.koldoon.fc.m.async.IAsyncCollection;

    /**
     * Async Collection Promise
     */
    public class AsyncCollection extends Promise implements IAsyncCollection {
        public function AsyncCollection() {
            items_ = new ArrayCollection();
        }


        public function get items():ArrayCollection {
            return items_;
        }


        public function applyResult(data:* = null):void {
            if (data is ArrayCollection) {
                items_.source = ArrayCollection(data).toArray();
            }
            else if (data is Array) {
                items_.source = data;
            }
            ready();
        }


        private var items_:ArrayCollection;
    }
}
