package ru.koldoon.fc.m.storage.impl.disk {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;

    public class LoadObjectOperation extends AbstractAsyncOperation {
        public function LoadObjectOperation(location:File) {
            this.location = location;
        }

        private var location:File;
        private var f:File;
        private var fs:FileStream;
        private var fileName:String;
        private var format:String = SerializationFormat.AMF;

        /**
         * Value Loaded
         */
        public var value:*;

        /**
         * Set Object Name to load
         * @param n
         * @return
         */
        public function name(n:String):LoadObjectOperation {
            this.fileName = n;
            return this;
        }

        public function serializationFormat(f:String):LoadObjectOperation {
            format = f;
            return this;
        }

        override public function execute():IAsyncOperation {
            status.setProcessing();
            super.execute();

            value = null;
            f = location.resolvePath(fileName);

            if (!fs) {
                fs = new FileStream();
                fs.addEventListener(Event.COMPLETE, fs_onComplete);
                fs.addEventListener(IOErrorEvent.IO_ERROR, fs_onIOError);
                fs.addEventListener(ProgressEvent.PROGRESS, fs_onProgress);
            }
            else {
                fs.close();
            }

            fs.openAsync(f, FileMode.READ);
            return this;
        }

        private function fs_onProgress(event:ProgressEvent):void {
            progress(event.bytesLoaded / event.bytesTotal * 100);
        }

        private function fs_onIOError(event:IOErrorEvent):void {
            fs.close();
            fault(event);
        }

        private function fs_onComplete(event:Event):void {
            var err:Boolean = false;
            try {
                if (format == SerializationFormat.AMF) {
                    value = fs.readObject();
                }
                else if (format == SerializationFormat.JSON) {
                    value = JSON.parse(fs.readUTFBytes(fs.bytesAvailable));
                }
                else {
                    err = true;
                }
            }
            catch (error:Error) {
                fs.close();
                fault(error);
            }

            if (err) {
                throw new Error("Unsupported serialization format: " + format);
            }

            if (!status.isFault) {
                fs.close();
                done();
            }
        }
    }
}
