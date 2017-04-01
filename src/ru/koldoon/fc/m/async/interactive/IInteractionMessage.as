package ru.koldoon.fc.m.async.interactive {
    public interface IInteractionMessage {
        /**
         * Interaction message type
         * @see InteractionMessageType
         */
        function get type():String;


        /**
         * Message display
         */
        function get text():String;


        /**
         * List of InteractionOption
         */
        function get options():Array;


        /**
         * Any extra Data associated with this question
         */
        function get data():*;


        /**
         * User response
         */
        function response(option:* = null):void;
    }
}
