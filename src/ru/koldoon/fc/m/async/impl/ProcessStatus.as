package ru.koldoon.fc.m.async.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IProcessStatus;

    /**
     * Common implementation of IProcessStatus
     */
    public class ProcessStatus implements IProcessStatus {

        /**
         * @inheritDoc
         */
        public function get isInited():Boolean {
            return status == INIT;
        }


        /**
         * @inheritDoc
         */
        public function get isComplete():Boolean {
            return status == COMPLETE;
        }


        /**
         * @inheritDoc
         */
        public function get isProcessing():Boolean {
            return status == IN_PROGRESS;
        }


        /**
         * @inheritDoc
         */
        public function get isPending():Boolean {
            return status == PENDING;
        }


        /**
         * @inheritDoc
         */
        public function get isUpdating():Boolean {
            return updating;
        }


        /**
         * @inheritDoc
         */
        public function get isFault():Boolean {
            return status == FAULT;
        }


        /**
         * @inheritDoc
         */
        public function get isCanceled():Boolean {
            return status == CANCEL;
        }


        /**
         * @inheritDoc
         */
        public function setPending():void {
            updating = status != INIT;
            status = PENDING
        }


        /**
         * @inheritDoc
         */
        public function setProcessing(updating:Boolean = false, data:* = null):void {
            this.updating = updating;
            status = IN_PROGRESS;
            if (_onStart) {
                _onStart.dispatch(data);
            }
        }


        /**
         * @inheritDoc
         */
        public function setComplete(data:* = null):void {
            updating = false;
            status = COMPLETE;
            if (_onComplete) {
                _onComplete.dispatch(data);
            }
            if (_onFinish) {
                _onFinish.dispatch(data);
            }
        }


        /**
         * @inheritDoc
         */
        public function setFault(data:* = null):void {
            status = FAULT;
            updating = false;
            if (_onFault) {
                _onFault.dispatch(data);
            }
            if (_onFinish) {
                _onFinish.dispatch(data);
            }
        }


        /**
         * @inheritDoc
         */
        public function setCanceled(data:* = null):void {
            status = CANCEL;
            updating = false;
            if (_onCancel) {
                _onCancel.dispatch(data);
            }
            if (_onFinish) {
                _onFinish.dispatch(data);
            }
        }


        /**
         * @inheritDoc
         */
        public function onComplete(handler:Function):IProcessStatus {
            if (!_onComplete) {
                _onComplete = new Signal();
            }
            _onComplete.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onStart(handler:Function):IProcessStatus {
            if (!_onStart) {
                _onStart = new Signal();
            }
            _onStart.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onFault(handler:Function):IProcessStatus {
            if (!_onFault) {
                _onFault = new Signal();
            }
            _onFault.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onCancel(handler:Function):IProcessStatus {
            if (!_onCancel) {
                _onCancel = new Signal();
            }
            _onCancel.addOnce(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onFinish(handler:Function):IProcessStatus {
            if (!_onFinish) {
                _onFinish = new Signal();
            }
            _onFinish.addOnce(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function removeEventHandler(handler:Function):void {
            if (_onStart) {
                _onStart.remove(handler);
            }
            if (_onFault) {
                _onFault.remove(handler);
            }
            if (_onCancel) {
                _onCancel.remove(handler);
            }
            if (_onFinish) {
                _onFinish.remove(handler);
            }
            if (_onComplete) {
                _onComplete.remove(handler);
            }
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private static const INIT:int = 0;
        private static const PENDING:int = 1;
        private static const IN_PROGRESS:int = 2;
        private static const COMPLETE:int = 3;
        private static const FAULT:int = 4;
        private static const CANCEL:int = 5;


        private var status:int = INIT;
        private var updating:Boolean = false;


        protected var _onStart:Signal;
        protected var _onFault:Signal;
        protected var _onCancel:Signal;
        protected var _onFinish:Signal;
        protected var _onComplete:Signal;

    }
}
