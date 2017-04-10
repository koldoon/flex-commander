package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IBindable;
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class AbstractBindableCommand extends AbstractCommand implements IBindable {


        /**
         * @inheritDoc
         */
        public function get id():String {
            return "";
        }


        /**
         * @inheritDoc
         */
        public function get label():String {
            return "";
        }


        /**
         * @inheritDoc
         */
        public function get description():String {
            return "";
        }


        /**
         * @inheritDoc
         */
        public function get bindings():Array {
            return _bindings;
        }


        public function set bindings(val:Array):void {
            _bindings = val;
        }


        /**
         * @inheritDoc
         */
        public function set context(val:BindingProperties):void {
            _context = val;
        }


        public function get context():BindingProperties {
            return _context;
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        private var _bindings:Array = [];
        private var _context:BindingProperties;
    }
}
