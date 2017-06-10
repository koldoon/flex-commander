package ru.koldoon.fc.m.async {
    /**
     * Async resource getting operation promise
     */

    public interface IAsyncOperation {

        /**
         * Operation Status.
         */
        function get status():IAsyncOperationStatus;


        /**
         * Trigger to start a progress defined by this operation.
         */
        function execute():IAsyncOperation;


        /**
         * Stops async process.
         */
        function cancel():void;

    }
}
