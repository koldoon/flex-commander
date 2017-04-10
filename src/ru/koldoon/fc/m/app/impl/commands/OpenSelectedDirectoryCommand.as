package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.IPromise;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;

    public class OpenSelectedDirectoryCommand extends AbstractBindableCommand {
        public function OpenSelectedDirectoryCommand() {
            bindings = [
                new BindingProperties("Enter")
            ];
        }


        /**
         * Last operation token.
         */
        private var listingPromise:IPromise;


        override public function isExecutable():Boolean {
            var sn:INode = app.getActivePanel().selectedNode;
            return sn == AbstractNode.PARENT_NODE || sn is IDirectory;
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            var node:INode = panel.selectedNode;
            var dir:IDirectory = node as IDirectory;

            if (listingPromise) {
                listingPromise.reject();
            }

            if (dir) {
                listingPromise = dir
                    .getListing()
                    .onReady(function (op:CollectionPromise):void {
                        listingPromise = null;
                        panel.selection.reset();
                        panel.directory = dir;
                        panel.selectedNodeIndex = 0;
                    });

                panel.setStatusText("Loading...");
            }
            else if (node == AbstractNode.PARENT_NODE) {
                var currentDir:IDirectory = panel.directory;
                var parentDir:IDirectory = currentDir.getParentDirectory();
                if (parentDir) {
                    panel.directory = parentDir;
                    panel.selectedNode = currentDir;
                }
            }
        }
    }
}
