package ru.koldoon.fc.m.app.impl.commands.copy {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodesBunchOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;
    import ru.koldoon.fc.m.tree.impl.fs.AbstractNodesBunchOperation;

    import spark.components.Button;

    public class CopyCommand extends AbstractBindableCommand {

        public static const OVERWRITE_ALL_EXISTING:String = "OVERWRITE_ALL_EXISTING";
        public static const SKIP_ALL_EXISTING:String = "SKIP_ALL_EXISTING";
        public static const PRESERVE_ATTRIBUTES:String = "PRESERVE_ATTRIBUTES";
        public static const FOLLOW_LINKS:String = "FOLLOW_LINKS";


        public function CopyCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("F5")
            ];
        }


        override public function isExecutable(target:String):Boolean {
            var sp:IPanel = app.leftPanel == app.getTargetPanel(target) ? app.leftPanel : app.rightPanel;
            var srcNodes:Array = sp.selection.length > 0 ? sp.selection.getSelectedNodes() : [sp.selectedNode];

            if (srcNodes.length == 1 && (!srcNodes[0] || srcNodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            return true;
        }


        override public function execute(target:String):void {
            srcPanel = app.leftPanel.selectedNodeIndex != -1 ? app.leftPanel : app.rightPanel;
            dstPanel = (srcPanel == app.leftPanel) ? app.rightPanel : app.leftPanel; // opposite panel
            srcNodes = srcPanel.selection.length > 0 ? srcPanel.selection.getSelectedNodes() : [srcPanel.selectedNode];
            srcDir = srcPanel.directory;
            dstDir = dstPanel.directory;
            srcTP = srcPanel.directory.getTreeProvider();
            dstTP = dstPanel.directory.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:CopyStartDialog = new CopyStartDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.nodesCount = srcNodes.length;
            p.targetDir = TreeUtils.getPathString(dstDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (srcNodes.length == 1) {
                p.nodeName = INode(srcNodes[0]).name;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    app.popupManager.remove(pd);
                }
                else if (p.okButton == e.target) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }

                followLinks = p.followSymlinks;
                preserveAttrs = p.preserveAttributes;
                overwriteAll = p.overwriteAll;
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    app.popupManager.remove(pd);
                }
                else if (e.keyCode == Keyboard.ENTER) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }
            }
        }


        private function beginCopy():void {
            if (ClassInfo.forInstance(srcTP).name == ClassInfo.forInstance(dstTP).name && srcTP is ITreeEditor) {
                copyWithTreeEditor();
            }
            else {
                // legacy operation through IFilesProvider
            }
        }


        /**
         * Stage 1: Collect all nodes to copy.
         */
        private function copyWithTreeEditor():void {
            var p:CopyPrepareDialog = new CopyPrepareDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var bytesTotal:Number = 0;

            selector = new NodesSelectionOperation()
                .sourceNodes(srcNodes)
                .treeProvider(srcTP)
                .recursive()
                .followLinks(followLinks);

            var te:ITreeEditor = srcTP as ITreeEditor;
            var cop:IAsyncOperation = te.copy(srcDir, dstDir, selector);
            var progressCursor:Number = 0;

            if (cop is IParametrized) {
                var parameters:IParameters = IParametrized(cop).getParameters();
                parameters.param(OVERWRITE_ALL_EXISTING).value = overwriteAll;
                parameters.param(PRESERVE_ATTRIBUTES).value = preserveAttrs;
                parameters.param(FOLLOW_LINKS).value = followLinks;
            }

            cop.getStatus()
                .onFinish(function (op:IAsyncOperation):void {
                    dstPanel.directory
                        .getListing()
                        .onReady(function (data:Object):void {
                            dstPanel.refresh();
                        });
                });

            selector.getProgress()
                .onProgress(function (op:NodesSelectionOperation):void {
                    bytesTotal += getBytesTotal(op.nodes.slice(progressCursor));
                    progressCursor = op.nodes.length;

                    p.percentDone = op.getProgress().percent || 0;
                    p.bytesTotal = bytesTotal;
                    p.itemsTotal = op.nodes.length;
                });

            selector.getStatus()
                .onComplete(function (op:NodesSelectionOperation):void {
                    showCopyProgressDialog(cop);
                })
                .onFinish(function (op:NodesSelectionOperation):void {
                    app.popupManager.remove(pd);
                });

            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    cop.cancel();
                }
                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    cop.cancel();
                }
            }
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


        private function showCopyProgressDialog(op:IAsyncOperation):void {
            var p:CopyProgressDialog = new CopyProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.nodesTotal = selector.nodes.length;
            p.targetDir = TreeUtils.getPathString(dstDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            op.getStatus()
                .onFinish(function (op:AbstractNodesBunchOperation):void {
                    app.popupManager.remove(pd);
                });

            if (op is IInteractiveOperation) {
                IInteractiveOperation(op)
                    .getInteraction()
                    .onMessage(onConfirmationMessage);
            }

            if (op is INodesBunchOperation) {
                INodesBunchOperation(op)
                    .getProgress()
                    .onProgress(function (op:INodesBunchOperation):void {
                        p.currentNode = TreeUtils.getPathString(op.nodes[op.nodesProcessed]);
                        p.nodesProcessed = op.nodesProcessed;
                    });
            }
            else {
                p.currentNode = "Not available";
                p.nodesProcessed = NaN;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    op.cancel();
                    app.popupManager.remove(pd);
                }
                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    op.cancel();
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


        private var srcPanel:IPanel;
        private var dstPanel:IPanel;
        private var srcTP:ITreeProvider;
        private var dstTP:ITreeProvider;
        private var srcDir:IDirectory;
        private var dstDir:IDirectory;

        private var srcNodes:Array;

        private var selector:NodesSelectionOperation;
        private var followLinks:Boolean;
        private var preserveAttrs:Boolean;
        private var overwriteAll:Boolean;
    }
}
