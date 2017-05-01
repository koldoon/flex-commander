package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.utils.notEmpty;

    public class OpenSelectedDirectoryCommand extends AbstractBindableCommand {
        public function OpenSelectedDirectoryCommand() {
            bindings = [
                new BindingProperties("Enter")
            ];
        }


        /**
         * Last operation token.
         */
        private var listingOperation:IAsyncOperation;


        override public function isExecutable():Boolean {
            var sn:INode = app.getActivePanel().selectedNode;
            return sn == AbstractNode.PARENT_NODE || sn is IDirectory;
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            var node:INode = panel.selectedNode;
            var dirToOpen:IDirectory = node as IDirectory;

            if (listingOperation && listingOperation.status.isProcessing) {
                listingOperation.cancel();
            }

            if (dirToOpen) {
                panel.setStatusText("Loading...");

                listingOperation = dirToOpen.refresh();
                listingOperation.status
                    .onStart(function (data:Object):void {
                        panel.enabled = false;
                    })
                    .onComplete(function (op:IAsyncOperation):void {
                        panel.selection.reset();
                        panel.directory = dirToOpen;
                        panel.selectedNodeIndex = 0;
                    })
                    .onFinish(function (op:IAsyncOperation):void {
                        panel.enabled = true;
                    });
            }
            else if (node == AbstractNode.PARENT_NODE) {
                var currentDir:IDirectory = panel.directory;
                var parentDir:IDirectory = currentDir.getParentDirectory();

                if (!parentDir) {
                    return;
                }

                if (notEmpty(parentDir.nodes)) {
                    panel.directory = parentDir;
                    panel.selectedNode = currentDir;
                }

                listingOperation = parentDir.refresh();
                listingOperation.status
                    .onComplete(function (op:IAsyncOperation):void {
                        panel.directory = parentDir;
                        panel.selection.reset();
                        panel.refresh();

                        var selectedNode:INode;
                        for each (var node:INode in parentDir.nodes) {
                            if (node.name == currentDir.name) {
                                selectedNode = node;
                                break
                            }
                        }
                        panel.selectedNode = node;
                    });
            }
        }
    }
}
