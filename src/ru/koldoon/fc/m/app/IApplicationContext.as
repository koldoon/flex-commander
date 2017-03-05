package ru.koldoon.fc.m.app {
    public interface IApplicationContext {

        /**
         * Register ICommand instance within application context and execute
         * module's <code>init()</code> method
         * @param cmd
         * @return
         */
        function installCommand(cmd:ICommand):Boolean;

    }
}
