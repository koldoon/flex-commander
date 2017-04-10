package ru.koldoon.fc.m.app.impl {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.ICommand;

    public class ApplicationContext implements IApplicationContext {
        public function ApplicationContext(app:IApplication) {
            this.app = app;
        }


        /**
         * @inheritDoc
         */
        public function installCommand(cmd:ICommand):Boolean {
            if (cmd.init(app)) {
                commands.push(cmd);
                return true;
            }
            return false;
        }


        public function get commandsInstalled():Vector.<ICommand> {
            return commands;
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        private var app:IApplication;
        private var commands:Vector.<ICommand> = new Vector.<ICommand>();

    }
}
