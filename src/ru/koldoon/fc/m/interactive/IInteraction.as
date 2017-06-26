package ru.koldoon.fc.m.interactive {
    /**
     * Interaction Line for interactive processes.
     * Allows ask questions and receive responses.
     */
    public interface IInteraction {
        /**
         * Get current user interaction message
         */
        function getMessage():IMessage;


        /**
         * Interactive process Message handler.
         * Usually messages pauses async process until user response
         * @param f handler like function(i:IInteraction):void
         */
        function onMessage(f:Function):IInteraction;


        function removeEventListener(h:Function):void;
    }
}
