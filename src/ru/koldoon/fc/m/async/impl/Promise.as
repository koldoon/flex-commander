package ru.koldoon.fc.m.async.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IPromise;

    public class Promise implements IPromise {

        public function onReady(handler:Function, unset:Boolean = false):IPromise {
            if (!onReady_) {
                onReady_ = new Signal();
            }
            if (unset) {
                onReady_.remove(handler);
            }
            else {
                onReady_.addOnce(handler);
            }
            return this;
        }


        public function onReject(handler:Function, unset:Boolean = false):IPromise {
            if (!onReject_) {
                onReject_ = new Signal();
            }
            if (unset) {
                onReject_.remove(handler);
            }
            else {
                onReject_.addOnce(handler);
            }
            return this;
        }


        public function ready():void {
            if (onReady_) {
                onReady_.dispatch(this);
            }
            onReady_ = null;
            onReject_ = null;
        }


        public function reject():void {
            if (onReject_) {
                onReject_.dispatch(this);
            }
            onReady_ = null;
            onReject_ = null;
        }


        private var onReady_:Signal;
        private var onReject_:Signal;
    }
}
