package ru.koldoon.fc.m.async {
    public interface IProgress {

        /**
         * Percent progress.
         */
        function get percent():Number;


        /**
         * Message, associated with current progress
         */
        function get message():String;


        /**
         * Message or percent change handler
         */
        function onProgress(handler:Function):IProgress;


        /**
         * Conventional method to remove handlers.
         * @param handler
         */
        function removeEventHandler(handler:Function):void;
    }
}
