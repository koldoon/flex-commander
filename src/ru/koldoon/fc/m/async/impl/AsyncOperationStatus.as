package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.IAsyncOperationStatus;

    public class AsyncOperationStatus implements IAsyncOperationStatus {
        private static const INIT:int = 0;
        private static const PENDING:int = 1;
        private static const IN_PROGRESS:int = 2;
        private static const COMPLETE:int = 3;
        private static const FAULT:int = 4;
        private static const CANCEL:int = 5;

        public function get isInited():Boolean {
            return status == INIT;
        }

        public function get isComplete():Boolean {
            return status == COMPLETE;
        }

        public function get isProcessing():Boolean {
            return status == IN_PROGRESS;
        }

        public function get isPending():Boolean {
            return status == PENDING;
        }

        public function get isUpdating():Boolean {
            return updating;
        }

        public function get isFault():Boolean {
            return status == FAULT;
        }

        public function get isCanceled():Boolean {
            return status == CANCEL;
        }


        public function setPending():void {
            updating = status != INIT;
            status = PENDING
        }

        public function setProcessing(isUpdating:Boolean = false):void {
            updating = isUpdating;
            status = IN_PROGRESS;
        }

        public function setComplete():void {
            updating = false;
            status = COMPLETE;
        }

        public function setFault():void {
            status = FAULT;
            updating = false;
        }

        public function setCanceled():void {
            status = CANCEL;
            updating = false;
        }

        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private var status:int = INIT;
        private var updating:Boolean = false;
    }
}
