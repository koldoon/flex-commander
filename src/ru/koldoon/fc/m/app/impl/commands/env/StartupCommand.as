package ru.koldoon.fc.m.app.impl.commands.env {
    import ru.koldoon.fc.conf.AppConfig;
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.app.impl.commands.mkdir.MakeDirectoryCommand;
    import ru.koldoon.fc.m.app.impl.commands.remove.RemoveCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.CopyCommand;
    import ru.koldoon.fc.m.app.impl.commands.transfer.impl.MoveCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.ILink;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.fs.LocalFileSystemTreeProvider;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_ResolvePathOperation;
    import ru.koldoon.fc.utils.notEmpty;

    public class StartupCommand extends AbstractCommand {
        private var context:IApplicationContext;


        override public function init(app:IApplication):Boolean {
            this.app = app;
            this.context = app.getContext();

            // context.installCommand(new InitMainMenuCommand());

            context.installCommand(new GoToLastNodeCommand());
            context.installCommand(new GoToFirstNodeCommand());
            context.installCommand(new GoToRootCommand());
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
                .status
                .onFinish(function (op:CommandLineOperation):void {
                    loadSettings();
                })
                .operation
                .execute();

            return false;
        }


        private function loadSettings():void {
            var fileSystemTreeProvider:ITreeProvider = new LocalFileSystemTreeProvider();

            if (notEmpty(AppConfig.getInstance().left_panel_path)) {
                initPanelDirectory(app.leftPanel, AppConfig.getInstance().left_panel_path, fileSystemTreeProvider);
            }
            else {
                app.leftPanel.directory = fileSystemTreeProvider.getRootDirectory();
                refreshPanel(app.leftPanel);
            }


            if (notEmpty(AppConfig.getInstance().right_panel_path)) {
                initPanelDirectory(app.rightPanel, AppConfig.getInstance().right_panel_path, fileSystemTreeProvider);
            }
            else {
                app.rightPanel.directory = fileSystemTreeProvider.getRootDirectory();
                refreshPanel(app.rightPanel);
            }
        }


        private function initPanelDirectory(panel:IPanel, path:String, provider:ITreeProvider):void {
            provider
                .resolvePathString(path)
                .status
                .onFinish(function (op:LFS_ResolvePathOperation):void {
                    var node:INode = op.getNode();
                    if (node is IDirectory) {
                        panel.directory = node as IDirectory;
                        refreshPanel(panel);
                    }
                    else if (node is ILink) {
                        provider
                            .resolveLink(node as ILink)
                            .status
                            .onFinish(function (op:ITreeGetNodeOperation):void {
                                if (op.getNode() is IDirectory) {
                                    panel.directory = op.getNode() as IDirectory;
                                }
                                else {
                                    panel.directory = provider.getRootDirectory();
                                }
                                refreshPanel(panel);
                            })
                            .operation
                            .execute();
                    }
                    else {
                        panel.directory = provider.getRootDirectory();
                        refreshPanel(panel);
                    }
                })
                .operation
                .execute();
        }


        private function refreshPanel(panel:IPanel):void {
            panel
                .directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    panel.refresh();
                });
        }

    }
}
