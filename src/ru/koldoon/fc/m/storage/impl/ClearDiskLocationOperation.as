package ru.koldoon.fc.m.storage.impl {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;

    public class ClearDiskLocationOperation extends AbstractAsyncOperation {
        public function ClearDiskLocationOperation(location:File) {
            super();
            this.location = location;
        }

        private var location:File;

        override public function execute():IAsyncOperation {
            status.setProcessing();
            if (location.isDirectory && location.exists) {
                location.addEventListener(Event.COMPLETE, onDeleteComplete);
                location.addEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
                location.deleteDirectoryAsync(true);
            }
            else {
                done();
            }
            return this;
        }

        private function onDeleteError(event:IOErrorEvent):void {
            location.removeEventListener(Event.COMPLETE, onDeleteComplete);
            location.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            fault(event);
        }

        private function onDeleteComplete(event:Event):void {
            location.removeEventListener(Event.COMPLETE, onDeleteComplete);
            location.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
            location.createDirectory();
            done();
        }
    }
}
