package ru.koldoon.fc.m.async {
    import ru.koldoon.fc.m.async.status.IProcessStatus;

    /**
     * Async resource getting operation promise
     */
    public interface IAsyncOperation {

        /**
         * Operation Status
         */
        function getStatus():IProcessStatus;


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
