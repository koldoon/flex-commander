package ru.koldoon.fc.m.async {
    public interface ICancelable {
        /**
         * Stop async process.
         */
        function cancel():void;

        /**
         * Cancel handler
         * @param handler function(op:ICancelable):void {}
         * @param unset
         * @return
         */
        function onCancel(handler:Function, unset:Boolean = false):ICancelable;
    }
}
