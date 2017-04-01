package ru.koldoon.fc.m.storage.impl {
    import flash.display.Shape;
    import flash.events.Event;

    import mx.collections.ArrayCollection;

    public class SelectDocumentsIndicesOperation extends AbstractProgressiveAsyncOperation {
        public function SelectDocumentsIndicesOperation(index:DocumentsIndex) {
            super();
            docsIndex = index;
            items_ = new ArrayCollection();
        }


        private var items_:ArrayCollection;
        private var docsIndex:DocumentsIndex;
        private var selectFilter:Function;
        private var selectLimit:Number = Number.MAX_VALUE;
        private var TICKER:Shape = new Shape();
        private var totalCount:Number;
        private var processingItemIndex:Number;


        /**
         * Result Items Collection
         * @return
         */
        public function get items():ArrayCollection {
            return items_;
        }


        public function filter(func:Function):SelectDocumentsIndicesOperation {
            selectFilter = func;
            return this;
        }


        public function limit(l:Number):SelectDocumentsIndicesOperation {
            selectLimit = l;
            return this;
        }


        override protected function begin():void {
            if (docsIndex.files.length > 0) {
                totalCount = docsIndex.files.length;
                processingItemIndex = 0;
                TICKER.addEventListener(Event.ENTER_FRAME, checkNextIndices);
            }
            else {
                done();
            }
        }


        private function checkNextIndices(event:Event = null):void {
            var indicesPerFrame:int = 100;

            if (docsIndex.files.length != totalCount) {
                TICKER.removeEventListener(Event.ENTER_FRAME, checkNextIndices);
                fault();
            }
            else {
                while (processingItemIndex < totalCount && processingItemIndex < selectLimit && indicesPerFrame > 0) {
                    if (selectFilter == null || selectFilter(docsIndex.files[processingItemIndex])) {
                        items_.addItem(docsIndex.files[processingItemIndex]);
                    }

                    indicesPerFrame -= 1;
                    processingItemIndex += 1;
                }

                items_.refresh();
                _progress.setPercent(processingItemIndex / totalCount * 100);

                if (processingItemIndex >= totalCount - 1) {
                    TICKER.removeEventListener(Event.ENTER_FRAME, checkNextIndices);
                    done();
                }
            }
        }
    }

}
