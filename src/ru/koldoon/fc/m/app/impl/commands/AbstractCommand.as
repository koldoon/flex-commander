package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.ICommand;

    public class AbstractCommand implements ICommand {

        public function init(app:IApplication):Boolean {
            this.app = app;
            return true;
        }


        public function isExecutable():Boolean {
            return true;
        }


        public function execute():void {
        }


        public function dispose():void {
        }


        protected var app:IApplication;
    }
}
