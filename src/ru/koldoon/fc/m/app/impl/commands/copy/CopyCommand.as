package ru.koldoon.fc.m.app.impl.commands.copy {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.c.confirmation.ConfirmationDialog;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.SelectNodesOperation;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodesBunchOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeTransmitOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;

    import spark.components.Button;

    public class CopyCommand extends AbstractBindableCommand {

        public function CopyCommand() {
            bindings = [
                new BindingProperties("F5")
            ];
        }


        override public function isExecutable():Boolean {
            var sp:IPanel = app.getActivePanel();
            var srcNodes:Array = sp.selection.length > 0 ? sp.selection.getSelectedNodes() : [sp.selectedNode];

            if (srcNodes.length == 1 && (!srcNodes[0] || srcNodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            return true;
        }


        override public function execute():void {
            srcPanel = app.getActivePanel();
            dstPanel = (srcPanel == app.leftPanel) ? app.rightPanel : app.leftPanel; // opposite panel
            srcNodes = srcPanel.selection.length > 0 ? srcPanel.selection.getSelectedNodes() : [srcPanel.selectedNode];
            srcDir = srcPanel.directory;
            dstDir = dstPanel.directory;
            srcTP = srcPanel.directory.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:CopyInitDialog = new CopyInitDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var te:ITreeEditor = srcTP as ITreeEditor;

            selector = new SelectNodesOperation()
                .sourceNodes(srcNodes)
                .treeProvider(srcTP)
                .recursive()
                .followLinks(false);

            copyOperation = te.copy()
                .setSource(srcDir)
                .setDestination(dstDir)
                .setSelector(selector);


            p.nodesCount = srcNodes.length;
            p.targetDir = TreeUtils.getPathString(dstDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (srcNodes.length == 1) {
                p.nodeName = INode(srcNodes[0]).name;
            }

            if (copyOperation is IParametrized) {
                p.parameters = IParametrized(copyOperation).getParameters().list;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    app.popupManager.remove(pd);
                    copyOperation.cancel();
                }
                else if (p.okButton == e.target) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    app.popupManager.remove(pd);
                    copyOperation.cancel();
                }
                else if (e.keyCode == Keyboard.ENTER) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }
            }
        }


        /**
         * Stage 1: Collect all nodes to copy.
         */
        private function beginCopy():void {
            var p:CopyPrepareDialog = new CopyPrepareDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var bytesTotal:Number = 0;
            var progressCursor:Number = 0;

            selector
                .getProgress()
                .onProgress(function (op:SelectNodesOperation):void {
                    bytesTotal += getBytesTotal(op.nodes.slice(progressCursor));
                    progressCursor = op.nodes.length;

                    p.percentDone = op.getProgress().percent || 0;
                    p.bytesTotal = bytesTotal;
                    p.itemsTotal = op.nodes.length;
                });

            selector
                .getStatus()
                .onComplete(function (op:SelectNodesOperation):void {
                    showCopyProgressDialog();
                })
                .onFinish(function (op:SelectNodesOperation):void {
                    app.popupManager.remove(pd);
                });

            copyOperation
                .execute();

            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    copyOperation.cancel();
                }
                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    copyOperation.cancel();
                }
            }
        }


        private function showCopyProgressDialog():void {
            var p:CopyProgressDialog = new CopyProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.nodesTotal = selector.nodes.length;
            p.targetDir = TreeUtils.getPathString(dstDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            copyOperation
                .getStatus()
                .onFinish(function (op:AbstractNodesBunchOperation):void {
                    dstPanel.directory
                        .getListing()
                        .onReady(function (data:Object):void {
                            app.popupManager.remove(pd);
                            srcPanel.selection.reset();
                            dstPanel.refresh();
                        });
                });

            if (copyOperation is IInteractiveOperation) {
                IInteractiveOperation(copyOperation)
                    .getInteraction()
                    .onMessage(onConfirmationMessage);
            }

            if (copyOperation is INodesBunchOperation) {
                INodesBunchOperation(copyOperation)
                    .getProgress()
                    .onProgress(function (op:INodesBunchOperation):void {
                        p.currentNode = TreeUtils.getPathString(op.nodesTotal[op.nodesProcessed]);
                        p.nodesProcessed = op.nodesProcessed;
                    });
            }
            else {
                p.currentNode = "Not available";
                p.nodesProcessed = NaN;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    copyOperation.cancel();
                    app.popupManager.remove(pd);
                }
                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    copyOperation.cancel();
                    app.popupManager.remove(pd);
                }
            }
        }


        private function onConfirmationMessage(i:IInteraction):void {
            var p:ConfirmationDialog = new ConfirmationDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true).inQueue(false);

            p.message = i.getMessage();
            p.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                if (e.target is Button) {
                    app.popupManager.remove(pd);
                }
            });
            p.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ENTER) {
                    // the first option if default
                    p.message.response(p.message.options[0]);
                    app.popupManager.remove(pd);
                }
            });
        }


        private function getBytesTotal(nodes:Array):Number {
            var bt:Number = 0;
            for (var i:int = 0; i < nodes.length; i++) {
                var fn:FileNode = nodes[i] as FileNode;
                if (fn && !(fn is DirectoryNode)) {
                    bt += fn.size;
                }
            }
            return bt;
        }


        private var srcPanel:IPanel;
        private var dstPanel:IPanel;
        private var srcTP:ITreeProvider;
        private var srcDir:IDirectory;
        private var dstDir:IDirectory;

        private var srcNodes:Array;

        private var selector:SelectNodesOperation;
        private var copyOperation:ITreeTransmitOperation;
    }
}
