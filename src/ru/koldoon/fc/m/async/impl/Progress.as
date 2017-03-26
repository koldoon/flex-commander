package ru.koldoon.fc.m.async.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IProgress;

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
            if (!_onProgress) {
                _onProgress = new Signal();
            }
            _onProgress.add(handler);
            return this;
        }


        public function removeEventHandler(handler:Function):void {
            if (_onProgress) {
                _onProgress.remove(handler);
            }
        }


        public function setPercent(p:Number):Progress {
            _percent = p;
            if (_onProgress) {
                _onProgress.dispatch();
            }
            return this;
        }


        public function setMessage(m:String):Progress {
            _message = m;
            if (_onProgress) {
                _onProgress.dispatch();
            }
            return this;
        }


        private var _percent:Number;
        private var _message:String;
        private var _onProgress:Signal;
    }
}
