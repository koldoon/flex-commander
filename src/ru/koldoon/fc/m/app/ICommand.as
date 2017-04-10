package ru.koldoon.fc.m.app {
    /**
     * Synchronous Command
     */
    public interface ICommand {

        // -----------------------------------------------------------------------------------
        // Life-Cycle
        // -----------------------------------------------------------------------------------

        /**
         * This method is executed when application starts and initializes all
         * commands available.
         * @return True on success. If init fails, this command is not added to context.
         * @param app Current Application Context
         */
        function init(app:IApplication):Boolean;


        /**
         * Check if command can be executed in current conditions
         */
        function isExecutable():Boolean;


        /**
         * Execute operation(s)
         */
        function execute():void;


        /**
         * Dispose command (when application closes).
         */
        function dispose():void;

    }
}
