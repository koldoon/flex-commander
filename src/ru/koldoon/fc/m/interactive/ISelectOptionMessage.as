package ru.koldoon.fc.m.interactive {

    [Bindable]
    public interface ISelectOptionMessage extends IMessage {
        /**
         * List of InteractionOption
         */
        function get options():Array;


        /**
         * User response
         */
        function response(option:* = null):void;

    }
}
