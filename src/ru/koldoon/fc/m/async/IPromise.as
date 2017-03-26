package ru.koldoon.fc.m.async {
    public interface IPromise {

        /**
         * Complete handler, no matter: positive or negative
         * function (op:IPromise):void {}
         * @param handler
         * @return
         */
        function onReady(handler:Function):IPromise;


        /**
         * Reject handler. If the target do not need data any more.
         * @param handler
         * @return
         */
        function onReject(handler:Function):IPromise;


        /**
         * Conventional method to remove handlers.
         * @param handler
         */
        function removeEventHandler(handler:Function):void;


        /**
         * Reject promise requested
         */
        function reject():void;


        /**
         * Apply promise
         */
        function ready():void;
    }
}
