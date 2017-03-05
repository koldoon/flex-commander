package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IBindable;
    import ru.koldoon.fc.m.app.ICommand;

    public class AbstractBindableCommand implements ICommand, IBindable {
        public function init(app:IApplication):Boolean {
            this.app = app;
            return true;
        }


        public function isExecutable(target:String):Boolean {
            return true;
        }


        public function execute(target:String):void {
        }


        public function dispose():void {
        }


        public function get id():String {
            return "";
        }


        public function get label():String {
            return "";
        }


        public function get description():String {
            return "";
        }


        public function get bindingProperties():Array {
            return bindingProperties_;
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        protected var app:IApplication;
        protected var bindingProperties_:Array = [];
    }
}
