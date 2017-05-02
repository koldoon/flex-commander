package ru.koldoon.fc.m.app.impl.commands.env {
    import ru.koldoon.fc.conf.AppConfig;
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.app.impl.commands.mkdir.MakeDirectoryCommand;
    import ru.koldoon.fc.m.app.impl.commands.remove.RemoveCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.CopyCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.MoveCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.fs.LocalFileSystemTreeProvider;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_ResolvePathOperation;
    import ru.koldoon.fc.utils.notEmpty;

    public class StartupCommand extends AbstractCommand {
        private var context:IApplicationContext;


        override public function init(app:IApplication):Boolean {
            this.app = app;
            this.context = app.getContext();

            context.installCommand(new InitMainMenuCommand());

            context.installCommand(new GoToLastNodeCommand());
            context.installCommand(new GoToFirstNodeCommand());
            context.installCommand(new SelectNodeCommand());
            context.installCommand(new ResetPanelSelectionCommand());
            context.installCommand(new OpenSelectedNodeCommand());
            context.installCommand(new CopyCommand());
            context.installCommand(new MoveCommand());
            context.installCommand(new RemoveCommand());
            context.installCommand(new MakeDirectoryCommand());
            context.installCommand(new SaveSettingsCommand());
            context.installCommand(new ShutdownCommand());

            new CommandLineOperation()
                .command("bin/init.sh")
                .execute()
                .status
                .onFinish(function (op:CommandLineOperation):void {
                    loadSettings();
                });

            return false;
        }


        private function loadSettings():void {
            var fileSystemTreeProvider:ITreeProvider = new LocalFileSystemTreeProvider();

            if (notEmpty(AppConfig.getInstance().left_panel_path)) {
                fileSystemTreeProvider
                    .resolvePathString(AppConfig.getInstance().left_panel_path)
                    .execute()
                    .status
                    .onFinish(function (op:LFS_ResolvePathOperation):void {
                        var node:INode = op.getNode();
                        if (node is IDirectory) {
                            app.leftPanel.directory = node as IDirectory;
                        }
                        else {
                            app.leftPanel.directory = fileSystemTreeProvider.getRootDirectory();
                        }
                        refreshLeftPanel();
                    });
            }
            else {
                app.leftPanel.directory = fileSystemTreeProvider.getRootDirectory();
                refreshLeftPanel();
            }

            if (notEmpty(AppConfig.getInstance().right_panel_path)) {
                fileSystemTreeProvider
                    .resolvePathString(AppConfig.getInstance().right_panel_path)
                    .execute()
                    .status
                    .onFinish(function (op:LFS_ResolvePathOperation):void {
                        var node:INode = op.getNode();
                        if (node is IDirectory) {
                            app.rightPanel.directory = node as IDirectory;
                        }
                        else {
                            app.rightPanel.directory = fileSystemTreeProvider.getRootDirectory();
                        }
                        refreshRightPanel();
                    });
            }
            else {
                app.rightPanel.directory = fileSystemTreeProvider.getRootDirectory();
                refreshRightPanel();
            }
        }


        private function refreshLeftPanel():void {
            app.leftPanel
                .directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    app.leftPanel.refresh();
                });
        }


        private function refreshRightPanel():void {
            app.rightPanel
                .directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    app.rightPanel.refresh();
                });
        }
    }
}
