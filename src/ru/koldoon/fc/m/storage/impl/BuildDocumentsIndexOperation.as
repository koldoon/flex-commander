package ru.koldoon.fc.m.storage.impl {
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.FileListEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;

    public class BuildDocumentsIndexOperation extends AbstractAsyncOperation {
        public function BuildDocumentsIndexOperation(location:File) {
            super();
            this.location = location;
        }


        private var docsIndex:DocumentsIndex;
        private var location:File;
        private var files:Array;
        private var filesCount:Number;
        private var processingItemIndex:Number;
        private var TICKER:Shape = new Shape();


        /**
         * Documents index to fill
         * @param i
         * @return
         */
        public function index(i:DocumentsIndex):BuildDocumentsIndexOperation {
            docsIndex = i;
            return this;
        }


        override public function execute():IAsyncOperation {
            status.setProcessing();

            if (!docsIndex) {
                docsIndex = new DocumentsIndex();
            }

            files = [];
            location.addEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
            location.getDirectoryListingAsync();
            return super.execute();
        }


        private function onDirectoryListing(event:FileListEvent):void {
            location.removeEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
            files = event.files;
            filesCount = files.length;

            if (filesCount > 0) {
                processingItemIndex = 0;
                TICKER.addEventListener(Event.ENTER_FRAME, processNextFiles);
            }
            else {
                done();
            }
        }


        private function processNextFiles(event:Event = null):void {
            var indicesPerFrame:int = 400;

            while (processingItemIndex < filesCount && indicesPerFrame > 0) {
                var f:File = files[processingItemIndex];
                if (f.name != "__COLLECTION_INDEX") {
                    docsIndex.files.push(f.name);
                }
                indicesPerFrame -= 1;
                processingItemIndex += 1;
            }

            progress(processingItemIndex / filesCount * 100);

            if (processingItemIndex >= filesCount - 1) {
                files = null;
                TICKER.removeEventListener(Event.ENTER_FRAME, processNextFiles);
                done();
            }
        }
    }
}
