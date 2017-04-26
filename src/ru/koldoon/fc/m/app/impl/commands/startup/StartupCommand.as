package ru.koldoon.fc.m.app.impl.commands.startup {
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.app.impl.commands.mkdir.MakeDirectoryCommand;
    import ru.koldoon.fc.m.app.impl.commands.remove.RemoveCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.CopyCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.MoveCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.impl.fs.LocalFileSystemTreeProvider;

    public class StartupCommand extends AbstractCommand {
        override public function init(app:IApplication):Boolean {
            var context:IApplicationContext = app.getContext();

            context.installCommand(new InitMainMenuCommand());

            context.installCommand(new GoToLastNodeCommand());
            context.installCommand(new GoToFirstNodeCommand());
            context.installCommand(new SelectNodeCommand());
            context.installCommand(new ResetPanelSelectionCommand());
            context.installCommand(new OpenSelectedFileCommand());
            context.installCommand(new OpenSelectedDirectoryCommand());
            context.installCommand(new CopyCommand());
            context.installCommand(new MoveCommand());
            context.installCommand(new RemoveCommand());
            context.installCommand(new MakeDirectoryCommand());

            app.leftPanel.directory = new LocalFileSystemTreeProvider().getRootDirectory();
            app.rightPanel.directory = new LocalFileSystemTreeProvider().getRootDirectory();

            app.leftPanel
                .directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    app.leftPanel.refresh();
                });


            app.rightPanel
                .directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    app.rightPanel.refresh();
                });


//            new LFS_ListingCLO()
//                .path("/Users/koldoon/tmp/0")
//                .recursive(true)
//                .execute()
//                .status
//                .onComplete(function (data:LFS_ListingCLO):void {
//                    trace(data.nodes.join("\n"));
//                    trace("total", FileNodeUtil.getFormattedSize(data.sizeTotal));
//                });

            return false;
        }
    }
}
