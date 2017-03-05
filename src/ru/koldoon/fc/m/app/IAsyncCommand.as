package ru.koldoon.fc.m.app {
    import org.osflash.signals.Signal;

    public interface IAsyncCommand extends ICommand {

        /**
         * Dispatch this signal when running is complete.
         */
        function get complete():Signal;


        /**
         * Command progress in percent
         */
        function get progress():Number;


        /**
         * Message to show during the progress
         */
        function get message():String;
    }
}
