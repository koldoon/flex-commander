package ru.koldoon.fc.m.interactive {

    [Bindable]
    public interface IMessage {
        /**
         * Message display
         */
        function get text():String;


        /**
         * Any extra Data associated with this message
         */
        function get data():*;
    }
}
