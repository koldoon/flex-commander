package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;

    public class GoToRootCommand extends AbstractBindableCommand {

        public function GoToRootCommand() {
            bindings = [
                new BindingProperties("Cmd-/")
            ];
        }


        override public function isExecutable():Boolean {
            return app.getActivePanel().directory;
        }


        private var listingOperation:IAsyncOperation;


        override public function execute():void {
            var ap:IPanel = app.getActivePanel();
            var dir:IDirectory = ap.directory.getTreeProvider().getRootDirectory();

            ap.directory = dir;
            ap.setStatusText("Loading...");
            ap.enabled = false;

            listingOperation = dir.refresh();
            listingOperation.status
                .onComplete(function (op:IAsyncOperation):void {
                    ap.selection.reset();
                    ap.directory = dir;
                    ap.selectedNodeIndex = 0;
                })
                .onFinish(function (op:IAsyncOperation):void {
                    ap.enabled = true;
                    ap.setStatusText("-");
                });
        }

    }
}
