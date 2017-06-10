package ru.koldoon.fc.m.async.impl {
    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.osflash.signals.Signal;
    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.IAsyncOperationStatus;

    /**
     * Common implementation of IAsyncOperationStatus state machine
     */
    public class ProcessStatus implements IAsyncOperationStatus {
        protected static var LOG:ILogger;


        public function ProcessStatus(op:IAsyncOperation) {
            LOG = Log.getLogger("fc." + ClassInfo.forInstance(this).simpleName);
            _hostOperation = op;
        }


        /**
         * @inheritDoc
         */
        public function get info():* {
            return _info;
        }


        public function set info(value:*):void {
            _info = value;
        }


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
        public function get isError():Boolean {
            return status == ERROR;
        }


        /**
         * @inheritDoc
         */
        public function get isCanceled():Boolean {
            return status == CANCEL;
        }


        /**
         * Set status to Pending.
         */
        public function setPending():void {
            updating = status != INIT;
            status = PENDING
        }


        /**
         * Set status to Processing and dispatch all appropriate signals
         * @param updating Set <code>updating</code> flag. Default is false.
         * @param data Any related data to pass to signal listener
         */
        public function setProcessing(updating:Boolean = false, data:* = null):void {
            this.updating = updating;
            status = IN_PROGRESS;
            _onStart && _onStart.dispatch(data);
        }


        /**
         * Set status to Complete.
         * @param data Any related data to pass to signal listener
         */
        public function setComplete(data:* = null):void {
            updating = false;
            status = COMPLETE;
            _onComplete && _onComplete.dispatch(data);
            _onFinish && _onFinish.dispatch(data);
        }


        /**
         * Set status to Fault.
         * @param data Any related data to pass to signal listener
         */
        public function setFault(data:* = null):void {
            status = ERROR;
            updating = false;
            _onError && _onError.dispatch(data);
            _onFinish && _onFinish.dispatch(data);
        }


        /**
         * Set status to Canceled.
         * @param data Any related data to pass to signal listener
         */
        public function setCanceled(data:* = null):void {
            status = CANCEL;
            updating = false;
            _onCancel && _onCancel.dispatch(data);
            _onFinish && _onFinish.dispatch(data);
        }


        /**
         * @inheritDoc
         */
        public function onComplete(handler:Function):IAsyncOperationStatus {
            !_onComplete && (_onComplete = new Signal());
            _onComplete.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onStart(handler:Function):IAsyncOperationStatus {
            !_onStart && (_onStart = new Signal());
            _onStart.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onError(handler:Function):IAsyncOperationStatus {
            !_onError && (_onError = new Signal());
            _onError.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onCancel(handler:Function):IAsyncOperationStatus {
            !_onCancel && (_onCancel = new Signal());
            _onCancel.addOnce(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onFinish(handler:Function):IAsyncOperationStatus {
            !_onFinish && (_onFinish = new Signal());
            _onFinish.addOnce(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function removeEventHandler(handler:Function):IAsyncOperationStatus {
            _onStart && _onStart.remove(handler);
            _onError && _onError.remove(handler);
            _onCancel && _onCancel.remove(handler);
            _onFinish && _onFinish.remove(handler);
            _onComplete && _onComplete.remove(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function get operation():IAsyncOperation {
            return _hostOperation;
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private static const INIT:int = 0;
        private static const PENDING:int = 1;
        private static const IN_PROGRESS:int = 2;
        private static const COMPLETE:int = 3;
        private static const ERROR:int = 4;
        private static const CANCEL:int = 5;


        private var status:int = INIT;
        private var updating:Boolean = false;
        private var _info:*;

        protected var _onStart:Signal;
        protected var _onError:Signal;
        protected var _onCancel:Signal;
        protected var _onFinish:Signal;
        protected var _onComplete:Signal;
        protected var _hostOperation:IAsyncOperation;

    }
}
