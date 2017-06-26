package ru.koldoon.fc.c.alert {
    import flash.events.IEventDispatcher;

    import spark.components.Button;

    public interface IMessageDisplayDialog extends IEventDispatcher {
        /**
         * Message Display
         */
        function setMessage(str:String):void;


        /**
         * Default Button to close the dialog
         */
        function getOkButton():Button;
    }
}
