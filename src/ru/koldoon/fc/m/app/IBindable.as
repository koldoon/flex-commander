package ru.koldoon.fc.m.app {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

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
         * Current binding properties, that triggered bindable instance
         */
        function set context(val:BindingProperties):void;

        function get context():BindingProperties;

        /**
         * Command must return it's binding options object when needed.
         * @see BindingProperties
         */
        [ArrayElementType("ru.koldoon.fc.m.app.impl.BindingProperties")]
        function get bindings():Array;
    }
}
