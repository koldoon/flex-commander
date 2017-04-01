package ru.koldoon.fc.m.async.interactive {
    /**
     * Interaction Line for interactive processes.
     * Allows ask questions and receive responses.
     */
    public interface IInteraction {
        /**
         * Get current user interaction message
         * @return
         */
        function getMessage():IInteractionMessage;


        /**
         * Interactive process Message handler.
         * Usually messages pauses async process until user response
         * @param f
         */
        function onMessage(f:Function):IInteraction;


        function removeEventListener(h:Function):void;
    }
}
