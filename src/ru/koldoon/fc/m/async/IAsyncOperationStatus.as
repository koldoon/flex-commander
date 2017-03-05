package ru.koldoon.fc.m.async {

    /**
     * Operation status switcher
     */
    public interface IAsyncOperationStatus {

        /**
         * Promise Object is just created and never processed before
         */
        function get isInited():Boolean;

        /**
         * Data getting is inited and waiting for
         * its turn to start processing
         */
        function get isPending():Boolean;

        /**
         * Data getting in progress
         */
        function get isProcessing():Boolean;

        /**
         * Operation is executed not the first time,
         * result data can be available already but dirty.
         */
        function get isUpdating():Boolean;

        /**
         * Data processing is finished
         */
        function get isComplete():Boolean;

        function get isCanceled():Boolean;

        function get isFault():Boolean;



        function setProcessing(updating:Boolean = false):void;

        function setComplete():void;

        function setPending():void;

        function setFault():void;

        function setCanceled():void;
    }
}
