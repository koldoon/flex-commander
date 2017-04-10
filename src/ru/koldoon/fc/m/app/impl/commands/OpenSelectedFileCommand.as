package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;

    public class OpenSelectedFileCommand extends AbstractBindableCommand {
        public function OpenSelectedFileCommand() {
            bindings = [
                new BindingProperties("Cmd-O"),
                new BindingProperties("Enter")
            ];

            // new BindingProperties("Enter", APP_RXP)
        }


        private static const APP_RXP:RegExp = /^.+\.app$/;


        override public function isExecutable():Boolean {
            var sn:INode = app.getActivePanel().selectedNode;
            return sn != AbstractNode.PARENT_NODE && !(sn is IDirectory);
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            var filesProvider:IFilesProvider = panel.selectedNode.getTreeProvider() as IFilesProvider;

            if (!filesProvider) {
                return;
            }

            filesProvider
                .getFiles([panel.selectedNode])
                .onReady(function (cp:CollectionPromise):void {
                    var ref:FileSystemReference = cp.items[0];
                    new CommandLineOperation()
                        .command("bin/open.sh")
                        .commandArguments([ref.path])
                        .execute();
                });
        }
    }
}