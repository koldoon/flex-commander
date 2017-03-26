package ru.koldoon.fc.m.async.impl {

    import flash.display.Shape;
    import flash.events.Event;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.IProcessStatus;

    public class AbstractAsyncOperation implements IAsyncOperation {
        protected static var LOG:ILogger;


        public function AbstractAsyncOperation() {
            LOG = Log.getLogger("fc." + ClassInfo.forInstance(this).simpleName);
            _status = new ProcessStatus();
        }


        public function get status():IProcessStatus {
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
            ticker.addEventListener(Event.ENTER_FRAME, function call_execute(e:Event):void {
                ticker.removeEventListener(Event.ENTER_FRAME, call_execute);

                _status.setProcessing(!status.isInited, this);
                begin();
            });
            return this;
        }


        protected function begin():void {
            throw new Error("You must implement abstract method begin()");
        }


        public function cancel():void {
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
                done();
            }
        }


        protected function done():void {
            _status.setComplete(this);
        }


        protected function fault():void {
            _status.setFault(this);
        }

    }
}
