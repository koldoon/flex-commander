package ru.koldoon.fc.m.storage.impl {
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.FileListEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Progress;
    import ru.koldoon.fc.m.async.progress.IProgress;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;

    public class BuildDocumentsIndexOperation extends AbstractAsyncOperation implements IProgressReporter {
        public function BuildDocumentsIndexOperation(location:File) {
            super();
            this.location = location;
        }


        private var _progress:Progress = new Progress();
        private var docsIndex:DocumentsIndex;
        private var location:File;
        private var files:Array;
        private var filesCount:Number;
        private var processingItemIndex:Number;
        private var TICKER:Shape = new Shape();


        public function get progress():IProgress {
            return _progress;
        }


        /**
         * Documents index to fill
         * @param i
         * @return
         */
        public function index(i:DocumentsIndex):BuildDocumentsIndexOperation {
            docsIndex = i;
            return this;
        }


        override protected function begin():void {
            if (!docsIndex) {
                docsIndex = new DocumentsIndex();
            }

            files = [];
            location.addEventListener(FileListEvent.DIRECTORY_LISTING, onDirectoryListing);
            location.getDirectoryListingAsync();
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

            _progress.setPercent(processingItemIndex / filesCount * 100, this);

            if (processingItemIndex >= filesCount - 1) {
                files = null;
                TICKER.removeEventListener(Event.ENTER_FRAME, processNextFiles);
                done();
            }
        }
    }
}
