package ru.koldoon.fc.m.app {

    /**
     * Synchronous Application Command.
     * Describes some application-level functionality
     */
    public interface ICommand {

        // -----------------------------------------------------------------------------------
        // Life-Cycle
        // -----------------------------------------------------------------------------------

        /**
         * This method is executed when application starts and initializes all
         * commands available.
         * Everything that has to be done at startup should be here.
         *
         * @return True on success. If init fails, this command is not added to context.
         * @param app Current Application Context
         */
        function init(app:IApplication):Boolean;


        /**
         * Simple Check if command can be executed in current conditions:
         * app and panels state, etc
         */
        function isExecutable():Boolean;


        /**
         * Execute operation(s)
         */
        function execute():void;


        /**
         * Dispose command (when application closes).
         * Put in this method everything, you want to be done before
         * application is closed: save settings, close active connections, etc.
         */
        function shutdown():void;

    }
}
