package ru.koldoon.fc.m.async {

    /**
     * Operation status switcher and notifier
     */
    public interface IProcessStatus {

        /**
         * Current status getters. To simplify checking
         * all getters organised as flags.
         */

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
        function get isFault():Boolean;


//        /**
//         * State machine methods.
//         * Use the following methods to track some process execution statuses
//         */
//
//        /**
//         * Set status to Processing and dispatch all appropriate signals
//         * @param updating Set <code>updating</code> flag. Default is false.
//         * @param data Any related data to pass to signal listener
//         */
//        function setProcessing(updating:Boolean = false, data:* = null):void;
//
//
//        /**
//         * Set status to Complete.
//         * @param data Any related data to pass to signal listener
//         */
//        function setComplete(data:* = null):void;
//
//
//        /**
//         * Set status to Pending.
//         */
//        function setPending():void;
//
//
//        /**
//         * Set status to Fault.
//         * @param data Any related data to pass to signal listener
//         */
//        function setFault(data:* = null):void;
//
//
//        /**
//         * Set status to Canceled.
//         * @param data Any related data to pass to signal listener
//         */
//        function setCanceled(data:* = null):void;
//

        /**
         * Status Change signals.
         */

        /**
         * Operation start Handler shortcut;
         */
        function onStart(handler:Function):IProcessStatus;


        /**
         * Process is completed with fault status.
         */
        function onFault(handler:Function):IProcessStatus;


        /**
         * Process is completed with Positive Status.
         */
        function onComplete(handler:Function):IProcessStatus;


        /**
         * Process is canceled.
         */
        function onCancel(handler:Function):IProcessStatus;


        /**
         * Process is completed with positive, negative or canceled status.
         * This handler will be executed at any finish status that stops the process
         * without further continue.
         */
        function onFinish(handler:Function):IProcessStatus;


        /**
         * Conventional method to remove event handlers.
         * Unset function that was used for any status changes handlers.
         * This the only method is introduced to simplify API, because
         * this operation needed really rarely.
         */
        function removeEventHandler(handler:Function):void;

    }
}
