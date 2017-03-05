package ru.koldoon.fc.m.app {
    /**
     * This Interface may be realised by ICommand or IAsyncCommand objects independently
     * @see ICommand
     * @see IAsyncCommand
     */
    public interface IBindable {

        // -----------------------------------------------------------------------------------
        // Self Description
        // -----------------------------------------------------------------------------------

        /**
         * Unique identifier (to store in the configuration)
         */
        function get id():String;


        /**
         * short label. Used in hints and bottom
         * function keys bar.
         */
        function get label():String;


        /**
         * full description. Used in config panel.
         */
        function get description():String;


        /**
         * Command must return it's binding options object when needed.
         * @see BindingProperties
         */
        [ArrayElementType("ru.koldoon.fc.m.app.impl.BindingProperties")]
        function get bindingProperties():Array;
    }
}
