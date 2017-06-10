package ru.koldoon.fc.m.app.impl.commands {
    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.ICommand;

    public class AbstractCommand implements ICommand {

        protected var LOG:ILogger;


        public function AbstractCommand() {
            LOG = Log.getLogger("fc" + ClassInfo.forInstance(this).simpleName);
        }


        public function init(app:IApplication):Boolean {
            this.app = app;
            return true;
        }


        public function isExecutable():Boolean {
            return true;
        }


        public function execute():void {
        }


        public function shutdown():void {
        }


        protected var app:IApplication;
    }
}
