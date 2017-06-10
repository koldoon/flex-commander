package ru.koldoon.fc.m.async {
    /**
     * Operation status switcher and notifier. Actual switching logic must be implemented
     * in concrete class
     * Supported STATUSES are:
     *
     *      - Inited
     *      - Pending
     *      - Processing
     *      - Updating
     *      - Complete
     *      - Canceled
     *      - Fault
     *
     */
    public interface IAsyncOperationStatus {

        // Current status getters. To simplify checking
        // all getters organised as flags.

        /**
         * Process instance was just created and have never
         * executed before.
         */
        function get isInited():Boolean;


        /**
         * Process is inited and waiting for
         * its turn to start (in some queue, etc)
         */
        function get isPending():Boolean;


        /**
         * Process is in progress
         */
        function get isProcessing():Boolean;


        /**
         * Flag shows that Process is executed not the first time,
         * result data can be available already but is probably dirty.
         */
        function get isUpdating():Boolean;


        /**
         * Process is finished, all result data is ready.
         */
        function get isComplete():Boolean;


        /**
         * Process is cancelled.
         */
        function get isCanceled():Boolean;


        /**
         * Process is finished with some error.
         */
        function get isError():Boolean;


        // Status Change signals.

        /**
         * Operation start Handler shortcut;
         */
        function onStart(handler:Function):IAsyncOperationStatus;


        /**
         * Process is completed with fault status.
         */
        function onError(handler:Function):IAsyncOperationStatus;


        /**
         * Process is completed with Positive Status.
         */
        function onComplete(handler:Function):IAsyncOperationStatus;


        /**
         * Process is canceled.
         */
        function onCancel(handler:Function):IAsyncOperationStatus;


        /**
         * Process is completed with positive, negative or canceled status.
         * This handler will be executed at any finish status that stops the process
         * without further continue.
         */
        function onFinish(handler:Function):IAsyncOperationStatus;


        /**
         * Conventional method to remove event handlers.
         * Unset function that was used for any status changes handlers.
         * This the only method is introduced to simplify API, because
         * this operation needed really rarely.
         */
        function removeEventHandler(handler:Function):IAsyncOperationStatus;


        /**
         * Host operation accessor to simplify using nice dot style continuous API
         * Example:
         * <code><pre>
         *   operation
         *      .status
         *      .onFinish(handler)
         *      .operation
         *      .execute();
         * </pre></code>
         */
        function get operation():IAsyncOperation;
    }
}
