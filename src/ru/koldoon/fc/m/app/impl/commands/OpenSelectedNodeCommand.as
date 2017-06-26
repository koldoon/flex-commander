package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.c.alert.ErrorDialog;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.AccessDeniedMessage;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.parametrized.impl.Param;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.ILink;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.utils.notEmpty;

    public class OpenSelectedNodeCommand extends AbstractBindableCommand {

        private static const FORCE_OPEN:String = "FORCE_OPEN";
        private static const APP_RXP:RegExp = /^.+\.app$/;


        public function OpenSelectedNodeCommand() {
            bindings = [
                new BindingProperties("Enter"),
                new BindingProperties("Cmd-O").setParams([new Param(FORCE_OPEN, true)])
            ];

            // Add this to enable auto open APP-s on Enter
            // new BindingProperties("Enter", APP_RXP)
        }


        /**
         * Last operation token.
         */
        private var listingOperation:IAsyncOperation;
        private var resolveOperation:IAsyncOperation;
        private var openOperation:IAsyncOperation;


        override public function isExecutable():Boolean {
            return app.getActivePanel().selectedNode !== null;
        }


        override public function execute():void {
            var ap:IPanel = app.getActivePanel();
            var tp:ITreeProvider = ap.directory.getTreeProvider();
            var node:INode = ap.selectedNode;
            var dirToOpen:IDirectory = node as IDirectory;
            var linkToOpen:ILink = node as ILink;
            var forceOpen:Boolean = context.parameters.param(FORCE_OPEN).value;

            cancelPreviousOperations();

            if (forceOpen) {
                openNodeByOS(node);
            }
            else if (dirToOpen) {
                openDirectory(dirToOpen);
            }
            else if (node == AbstractNode.PARENT_NODE) {
                openParentDirectory();
            }
            else if (linkToOpen) {
                resolveOperation = tp
                    .resolveLink(linkToOpen)
                    .status
                    .onComplete(function (op:ITreeGetNodeOperation):void {
                        var node:INode = op.getNode();
                        if (node is IDirectory) {
                            openDirectory(node as IDirectory);
                        }
                        else if (node) {
                            openNodeByOS(node);
                        }
                    })
                    .operation
                    .execute();
            }
            else {
                openNodeByOS(node);
            }
        }


        private function cancelPreviousOperations():void {
            if (listingOperation && listingOperation.status.isProcessing) {
                listingOperation.cancel();
            }

            if (resolveOperation && resolveOperation.status.isProcessing) {
                resolveOperation.cancel();
            }
        }


        private function openDirectory(dir:IDirectory):void {
            var ap:IPanel = app.getActivePanel();
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

            if (listingOperation is IInteractive) {
                IInteractive(listingOperation)
                    .interaction
                    .onMessage(function (i:IInteraction):void {
                        var adMsg:AccessDeniedMessage = i.getMessage() as AccessDeniedMessage;
                        if (adMsg) {
                            var p:ErrorDialog = new ErrorDialog();
                            p.setMessage(adMsg.text);
                            app.popupManager.add().instance(p);
                        }
                    });
            }
        }


        private function openParentDirectory():void {
            var ap:IPanel = app.getActivePanel();
            var currentDir:IDirectory = ap.directory;


            // node before parent dir
            // if there are links in sequence, this node can be an ILink instance
            // and not the current dir at all.
            var selectedNode:INode = currentDir;
            var p:INode = currentDir.parent;

            // looking for parent dir
            while (p && !(p is IDirectory)) {
                selectedNode = p;
                p = p.parent;
            }

            var parentDir:IDirectory = p as IDirectory;

            if (!parentDir) {
                return;
            }

            if (notEmpty(parentDir.nodes)) {
                ap.directory = parentDir;
                ap.selectedNode = selectedNode;
            }

            listingOperation = parentDir.refresh();
            listingOperation.status
                .onComplete(function (op:IAsyncOperation):void {
                    ap.directory = parentDir;
                    ap.selection.reset();
                    ap.refresh();

                    // instances after refresh are re-created,
                    // so we have to look for a particular node by name
                    var sameSelectedNode:INode;
                    for each (var node:INode in parentDir.nodes) {
                        if (node.name == selectedNode.name) {
                            sameSelectedNode = node;
                            break
                        }
                    }
                    ap.selectedNode = sameSelectedNode;
                });
        }


        private function openNodeByOS(node:INode):void {
            openOperation = new CommandLineOperation()
                .command("bin/open")
                .commandArguments([FileNodeUtil.getPath(node)])
                .execute();
        }

    }
}
