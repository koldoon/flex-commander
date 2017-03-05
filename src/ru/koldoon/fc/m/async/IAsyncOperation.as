package ru.koldoon.fc.m.async {
    /**
     * Async resource getting operation promise
     */
    public interface IAsyncOperation extends ICancelable {

        /**
         * Operation Status
         */
        function get status():IAsyncOperationStatus;

        /**
         * Operation start Handler shortcut;
         * @param handler function(op:IAsyncOperation):void {}
         * @param unset
         * @return
         */
        function onStart(handler:Function, unset:Boolean = false):IAsyncOperation;

        /**
         * @param handler function(op:IAsyncOperation):void {}
         * @param unset remove handler given
         * @return
         */
        function onResult(handler:Function, unset:Boolean = false):IAsyncOperation;

        /**
         * Progress change handler: function (op:IAsyncOperation):void {}
         * @param handler
         * @param unset
         * @return
         */
        function onProgress(handler:Function, unset:Boolean = false):IAsyncOperation;

        /**
         * Fault handler;
         * @param handler function(op:IAsyncOperation):void {}
         * @param unset
         * @return
         */
        function onFault(handler:Function, unset:Boolean = false):IAsyncOperation;


        /**
         * Trigger to start a progress defined by this operation.
         */
        function execute():IAsyncOperation;

        /**
         * Complete handler, no matter: positive or negative.
         * @param handler function(op:IAsyncOperation):void {}
         * @param unset
         * @return
         */
        function onComplete(handler:Function, unset:Boolean = false):IAsyncOperation;

    }
}
