package ru.koldoon.fc.m.progress.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.progress.IProgress;

    /**
     * Basic implementation of IProgress
     */
    public class Progress implements IProgress {

        public function get percent():Number {
            return _percent;
        }


        public function get message():String {
            return _message;
        }


        public function onProgress(handler:Function):IProgress {
            if (!updated) {
                updated = new Signal();
            }
            updated.add(handler);
            return this;
        }


        public function removeEventHandler(handler:Function):void {
            if (updated) {
                updated.remove(handler);
            }
        }


        public function setPercent(p:Number, operation:*):Progress {
            _percent = p;
            if (updated) {
                updated.dispatch(operation);
            }
            return this;
        }


        public function setMessage(m:String, operation:*):Progress {
            _message = m;
            if (updated) {
                updated.dispatch(operation);
            }
            return this;
        }


        private var _percent:Number;
        private var _message:String;
        private var updated:Signal;
    }
}
