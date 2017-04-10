package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.impl.commands.copy.CopyCommand;
    import ru.koldoon.fc.m.app.impl.commands.remove.RemoveCommand;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.tree.impl.fs.LocalFileSystemTreeProvider;

    public class StartupCommand extends AbstractCommand {
        override public function init(app:IApplication):Boolean {
            var context:IApplicationContext = app.getContext();

            context.installCommand(new GoToLastNodeCommand());
            context.installCommand(new GoToFirstNodeCommand());
            context.installCommand(new SelectNodeCommand());
            context.installCommand(new ResetPanelSelectionCommand());
            context.installCommand(new OpenSelectedFileCommand());
            context.installCommand(new OpenSelectedDirectoryCommand());
            context.installCommand(new CopyCommand());
            context.installCommand(new RemoveCommand());

            app.leftPanel.directory = new LocalFileSystemTreeProvider().getRootDirectory();
            app.rightPanel.directory = new LocalFileSystemTreeProvider().getRootDirectory();

            app.leftPanel
                .directory
                .getListing()
                .onReady(function (ac:ICollectionPromise):void {
                    app.leftPanel.refresh();
                });


            app.rightPanel
                .directory
                .getListing()
                .onReady(function (ac:ICollectionPromise):void {
                    app.rightPanel.refresh();
                });

            return false;
        }
    }
}
