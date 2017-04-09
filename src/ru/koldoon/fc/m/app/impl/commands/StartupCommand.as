package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.ICommand;
    import ru.koldoon.fc.m.app.impl.commands.copy.CopyCommand;
    import ru.koldoon.fc.m.app.impl.commands.remove.RemoveCommand;

    public class StartupCommand implements ICommand {
        public function init(app:IApplication):Boolean {
            app.context.installCommand(new GoToLastNodeCommand());
            app.context.installCommand(new GoToFirstNodeCommand());
            app.context.installCommand(new SelectNodeCommand());
            app.context.installCommand(new ResetPanelSelectionCommand());
            app.context.installCommand(new OpenMacApplicationCommand());
            app.context.installCommand(new OpenSelectedNodeCommand());
            app.context.installCommand(new CopyCommand());
            app.context.installCommand(new RemoveCommand());

            return false;
        }


        public function isExecutable(target:String):Boolean {
            return false;
        }


        public function execute(target:String):void {
        }


        public function dispose():void {
        }
    }
}
