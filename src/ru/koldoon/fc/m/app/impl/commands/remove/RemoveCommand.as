package ru.koldoon.fc.m.app.impl.commands.remove {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.AbstractBindableCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodesBunchOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;

    public class RemoveCommand extends AbstractBindableCommand {

        public function RemoveCommand() {
            bindingProperties_ = [
                new BindingProperties("F8")
            ];
        }


        override public function isExecutable(target:String):Boolean {
            var sp:IPanel = app.getActivePanel();
            var srcNodes:Array = sp.selection.length > 0 ? sp.selection.getSelectedNodes() : [sp.selectedNode];

            if (srcNodes.length == 1 && (!srcNodes[0] || srcNodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            return true;
        }


        override public function execute(target:String):void {
            srcPanel = app.getActivePanel();
            srcNodes = srcPanel.selection.length > 0 ? srcPanel.selection.getSelectedNodes() : [srcPanel.selectedNode];
            srcDir = srcPanel.directory;
            srcTP = srcPanel.directory.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:RemoveInitDialog = new RemoveInitDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var te:ITreeEditor = srcTP as ITreeEditor;

            removeOperation = te.remove(srcNodes);

            p.nodesCount = srcNodes.length;
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (srcNodes.length == 1) {
                p.nodeName = "\"" + INode(srcNodes[0]).name + "\"";
            }

            if (removeOperation is IParametrized) {
                p.parameters = IParametrized(removeOperation).getParameters().list;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    app.popupManager.remove(pd);
                }
                else if (p.okButton == e.target) {
                    app.popupManager.remove(pd);
                    beginRemove();
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    app.popupManager.remove(pd);
                }
                else if (e.keyCode == Keyboard.ENTER) {
                    app.popupManager.remove(pd);
                    beginRemove();
                }
            }
        }


        private function beginRemove():void {
            var p:RemoveProgressDialog = new RemoveProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            removeOperation
                .execute()
                .getStatus()
                .onFinish(function (op:AbstractNodesBunchOperation):void {
                    srcPanel.directory
                        .getListing()
                        .onReady(function (data:Object):void {
                            app.popupManager.remove(pd);
                            srcPanel.selection.reset();
                            srcPanel.refresh();
                        });
                });


            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (removeOperation is INodesBunchOperation) {
                INodesBunchOperation(removeOperation)
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
                    removeOperation.cancel();
                    app.popupManager.remove(pd);
                }
                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    removeOperation.cancel();
                    app.popupManager.remove(pd);
                }
            }
        }


        private var srcPanel:IPanel;
        private var srcTP:ITreeProvider;
        private var srcDir:IDirectory;

        private var srcNodes:Array;
        private var removeOperation:IAsyncOperation;
    }
}
