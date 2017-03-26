package ru.koldoon.fc.m.async {
    public interface IInteractiveOperation extends IAsyncOperation {

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
        function onMessage(f:Function):IInteractiveOperation;

    }
}
