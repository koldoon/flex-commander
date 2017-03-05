package ru.koldoon.fc.m.async {
    public interface IPromise {

        /**
         * Complete handler, no matter: positive or negative
         * function (op:IPromise):void {}
         * @param handler
         * @param unset
         * @return
         */
        function onReady(handler:Function, unset:Boolean = false):IPromise;

        function onReject(handler:Function, unset:Boolean = false):IPromise;


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
