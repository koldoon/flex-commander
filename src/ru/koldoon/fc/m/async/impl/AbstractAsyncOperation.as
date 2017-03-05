package ru.koldoon.fc.m.async.impl {

    import flash.display.Shape;
    import flash.events.Event;

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.IAsyncOperationStatus;
    import ru.koldoon.fc.m.async.ICancelable;

    public class AbstractAsyncOperation implements IAsyncOperation {
        public function AbstractAsyncOperation() {
            _status = new AsyncOperationStatus();
        }


        public function get status():IAsyncOperationStatus {
            return _status;
        }


        public function onProgress(handler:Function, unset:Boolean = false):IAsyncOperation {
            if (!_onProgress) {
                _onProgress = new Signal();
            }

            if (unset) {
                _onProgress.remove(handler);
            }
            else {
                _onProgress.add(handler);
            }
            return this;
        }


        public function onComplete(handler:Function, unset:Boolean = false):IAsyncOperation {
            if (!_onComplete) {
                _onComplete = new Signal();
            }

            if (unset) {
                _onComplete.remove(handler);
            }
            else {
                _onComplete.add(handler);
            }
            return this;
        }


        public function onStart(handler:Function, unset:Boolean = false):IAsyncOperation {
            if (!_onStart) {
                _onStart = new Signal();
            }

            if (unset) {
                _onStart.remove(handler);
            }
            else {
                _onStart.add(handler);
            }
            return this;
        }


        public function onFault(handler:Function, unset:Boolean = false):IAsyncOperation {
            if (!_onFault) {
                _onFault = new Signal();
            }

            if (unset) {
                _onFault.remove(handler);
            }
            else {
                _onFault.add(handler);
            }
            return this;
        }


        public function onResult(handler:Function, unset:Boolean = false):IAsyncOperation {
            if (!_onResult) {
                _onResult = new Signal();
            }

            if (unset) {
                _onResult.remove(handler);
            }
            else {
                _onResult.add(handler);
            }
            return this;
        }


        public function onCancel(handler:Function, unset:Boolean = false):ICancelable {
            if (!_onCancel) {
                _onCancel = new Signal();
            }

            if (unset) {
                _onCancel.remove(handler);
            }
            else {
                _onCancel.add(handler);
            }
            return this;
        }


        public function execute():IAsyncOperation {
            if (_onStart) {
                _onStart.dispatch(this);
            }
            return this;
        }


        public function cancel():void {
            status.setCanceled();
            if (_onCancel) {
                _onCancel.dispatch(this);
            }
            if (_onComplete) {
                _onComplete.dispatch(this);
            }
            dispose();
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        protected var _ticker:Shape = new Shape();
        protected var _status:AsyncOperationStatus;
        protected var _onComplete:Signal;
        protected var _onStart:Signal;
        protected var _onResult:Signal;
        protected var _onFault:Signal;
        protected var _onProgress:Signal;
        protected var _onCancel:Signal;


        /**
         * Call this method if you need to apply <code>done()</code> in the next frame
         */
        public function doneAsync():void {
            _ticker.addEventListener(Event.ENTER_FRAME, callDone);
            function callDone(e:Event):void {
                _ticker.removeEventListener(Event.ENTER_FRAME, callDone);
                done();
            }
        }


        public function done():void {
            status.setComplete();
            if (_onResult) {
                _onResult.dispatch(this);
            }
            if (_onComplete) {
                _onComplete.dispatch(this);
            }
            dispose();
        }


        public function fault(data:* = null):void {
            status.setFault();
            if (_onFault) {
                _onFault.dispatch(data);
            }
            if (_onComplete) {
                _onComplete.dispatch(this);
            }
            dispose();
        }


        public function progress(data:* = null):void {
            if (_onProgress) {
                _onProgress.dispatch(this);
            }
        }


        protected function dispose():void {
            _onProgress = null;
            _onResult = null;
            _onStart = null;
            _onFault = null;
            _onComplete = null;
        }
    }
}
