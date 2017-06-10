package ru.koldoon.fc.m.async.impl {

    import flash.display.Shape;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.IAsyncOperationStatus;

    public class AbstractAsyncOperation implements IAsyncOperation {

        /**
         * Created and not disposed operations references. Can be used in DEBUG purposes.
         */
        public static var OPERATIONS:Dictionary = new Dictionary(true);
        protected var LOG:ILogger;


        public function AbstractAsyncOperation() {
            _status = new ProcessStatus(this);
            OPERATIONS[this] = getTimer();
            LOG = Log.getLogger("fc." + ClassInfo.forInstance(this).simpleName);
        }


        public function get status():IAsyncOperationStatus {
            return _status;
        }


        /**
         * Execute command.
         * Do not override this method! Otherwise async execution will not
         * be working properly!
         * To implement custom Operation, you must overwrite <code>begin</code>
         * method instead.
         */
        public function execute():IAsyncOperation {
            if (status.isProcessing) {
                return this;
            }

            LOG.debug("Starting");
            _status.setProcessing(!_status.isInited, this);
            begin();
            return this;
        }


        public function executeAsync():AbstractAsyncOperation {
            var self:AbstractAsyncOperation = this;

            ticker.addEventListener(Event.ENTER_FRAME, function call_execute(e:Event):void {
                ticker.removeEventListener(Event.ENTER_FRAME, call_execute);

                if (!_status.isCanceled) {
                    LOG.debug("Starting");
                    _status.setProcessing(!_status.isInited, self);
                    begin();
                }
            });

            return this;
        }


        protected function begin():void {
            throw new Error("You must implement abstract method begin()");
        }


        public function cancel():void {
            LOG.warn("Cancelled");
            _status.setCanceled(this);
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        protected static var ticker:Shape = new Shape();
        protected var _status:ProcessStatus;


        /**
         * Call this method if you need to apply <code>done()</code> in the next frame
         */
        protected function doneAsync():void {
            ticker.addEventListener(Event.ENTER_FRAME, callDone);
            function callDone(e:Event):void {
                ticker.removeEventListener(Event.ENTER_FRAME, callDone);
                if (!_status.isCanceled && !_status.isError && !_status.isComplete) {
                    done();
                }
            }
        }


        protected function done():void {
            LOG.debug("Completed");
            if (!_status.isCanceled && !_status.isError) {
                _status.setComplete(this);
            }
        }


        protected function fault():void {
            LOG.error("Fault");
            _status.setFault(this);
        }

    }
}
