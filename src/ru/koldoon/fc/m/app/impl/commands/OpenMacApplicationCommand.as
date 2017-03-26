package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.impl.AsyncCollection;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;

    public class OpenMacApplicationCommand extends AbstractBindableCommand {
        public function OpenMacApplicationCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("Cmd-O"),
                new BindingProperties("Enter", APP_RXP)
            ];
        }


        private static const APP_RXP:RegExp = /^.+\.app$/;


        override public function execute(target:String):void {
            var panel:IPanel = app.getTargetPanel(target);
            var filesProvider:IFilesProvider = panel.selectedNode.getTreeProvider() as IFilesProvider;

            if (!filesProvider) {
                return;
            }

            filesProvider
                .getFiles([panel.selectedNode])
                .onReady(function (ac:AsyncCollection):void {
                    var ref:FileSystemReference = ac.items[0];
                    new CommandLineOperation()
                        .command("bin/open.sh")
                        .commandArguments(ref.path)
                        .execute();
                });
        }
    }
}
