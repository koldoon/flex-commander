package ru.koldoon.fc.m.storage.impl.disk {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import ru.koldoon.fc.m.async.impl.AbstractProgressiveAsyncOperation;

    public class SaveObjectOperation extends AbstractProgressiveAsyncOperation {
        public function SaveObjectOperation(location:File) {
            this.location = location;
        }


        private var value:*;
        private var fileName:String;
        private var f:File;
        private var fs:FileStream;
        private var location:File;
        private var format:String = SerializationFormat.AMF;


        public function object(name:String, value:*):SaveObjectOperation {
            this.value = value;
            this.fileName = name;
            return this;
        }


        public function serializationFormat(f:String):SaveObjectOperation {
            format = f;
            return this;
        }


        override protected function begin():void {
            if (!fs) {
                fs = new FileStream();
                fs.addEventListener(ProgressEvent.PROGRESS, fs_onProgress);
                fs.addEventListener(IOErrorEvent.IO_ERROR, fs_onIOError);
                fs.addEventListener(Event.CLOSE, fs_onClose);
            }

            f = location.resolvePath(fileName);
            fs.openAsync(f, FileMode.WRITE);

            if (format == SerializationFormat.AMF) {
                fs.writeObject(value);
            }
            else if (format == SerializationFormat.JSON) {
                fs.writeUTFBytes(JSON.stringify(value, null, 4));
            }
            else {
                throw new Error("Unsupported serialization format: " + format);
            }

            fs.close();
        }


        private function fs_onProgress(event:ProgressEvent):void {
            progress_.setPercent(event.bytesLoaded / event.bytesTotal * 100);
        }


        private function fs_onIOError(event:IOErrorEvent):void {
            fault();
        }


        protected function fs_onClose(event:Event):void {
            done();
        }
    }
}
