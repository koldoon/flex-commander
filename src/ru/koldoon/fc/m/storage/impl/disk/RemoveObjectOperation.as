package ru.koldoon.fc.m.storage.impl.disk {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;

    public class RemoveObjectOperation extends AbstractAsyncOperation {
        public function RemoveObjectOperation(location:File) {
            super();
            this.location = location;
        }


        private var fileName:String;
        private var f:File;
        private var location:File;


        public function name(n:String):RemoveObjectOperation {
            this.fileName = n;
            return this;
        }


        override protected function begin():void {
            f = location.resolvePath(fileName);
            f.addEventListener(IOErrorEvent.IO_ERROR, f_onIOError);
            f.addEventListener(Event.COMPLETE, f_onComplete);
            f.deleteFileAsync();
        }


        private function f_onComplete(event:Event):void {
            f.removeEventListener(IOErrorEvent.IO_ERROR, f_onIOError);
            f.removeEventListener(Event.COMPLETE, f_onComplete);
            done();
        }


        private function f_onIOError(event:IOErrorEvent):void {
            f.removeEventListener(IOErrorEvent.IO_ERROR, f_onIOError);
            f.removeEventListener(Event.COMPLETE, f_onComplete);
            fault();
        }

    }
}
