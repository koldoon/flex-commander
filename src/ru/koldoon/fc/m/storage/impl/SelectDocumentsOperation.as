package ru.koldoon.fc.m.storage.impl {
    import flash.display.Shape;
    import flash.events.Event;
    import flash.filesystem.File;

    import mx.collections.ArrayCollection;

    import ru.koldoon.fc.m.async.impl.AbstractProgressiveAsyncOperation;
    import ru.koldoon.fc.m.storage.impl.disk.LoadObjectOperation;

    public class SelectDocumentsOperation extends AbstractProgressiveAsyncOperation {
        public function SelectDocumentsOperation(location:File, index:DocumentsIndex) {
            super();
            this.location = location;
            this.docsIndex = index;
            items_ = new ArrayCollection();
        }


        private var items_:ArrayCollection;
        private var docsIndex:DocumentsIndex;
        private var selectFilter:Function;
        private var selectLimit:Number = Number.MAX_VALUE;
        private var location:File;
        private var totalCount:Number;
        private var processingItemIndex:Number;
        private var itemLoader:LoadObjectOperation;
        private var TICKER:Shape = new Shape();


        /**
         * Result Items Collection
         * @return
         */
        public function get items():ArrayCollection {
            return items_;
        }


        public function filter(func:Function):SelectDocumentsOperation {
            selectFilter = func;
            return this;
        }


        public function limit(l:Number):SelectDocumentsOperation {
            selectLimit = l;
            return this;
        }


        override protected function begin():void {
            if (docsIndex.files.length > 0) {
                totalCount = docsIndex.files.length;
                processingItemIndex = 0;
                itemLoader = new LoadObjectOperation(location);
                TICKER.addEventListener(Event.ENTER_FRAME, beginSelect);
            }
            else {
                done();
            }
        }


        private function beginSelect(event:Event):void {
            TICKER.removeEventListener(Event.ENTER_FRAME, beginSelect);
            checkNextFile();
        }


        private function checkNextFile(event:Event = null):void {
            if (docsIndex.files.length != totalCount) {
                fault();
            }
            else {
                if (processingItemIndex >= totalCount || processingItemIndex >= selectLimit) {
                    done();
                }
                else {
                    itemLoader
                        .name(docsIndex.files[processingItemIndex])
                        .execute();

                    itemLoader.status
                        .onComplete(function (op:LoadObjectOperation):void {
                            if (selectFilter == null || selectFilter(op.value)) {
                                items.addItem(op.value);
                            }
                            TICKER.addEventListener(Event.ENTER_FRAME, beginSelect);
                        });


                    processingItemIndex += 1;
                    progress_.setPercent(processingItemIndex / totalCount * 100);
                }
            }
        }
    }
}
