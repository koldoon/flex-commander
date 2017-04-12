package ru.koldoon.fc.m.app.impl.commands.remove {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.AbstractBindableCommand;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.parametrized.IParam;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodesBunchOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;

    public class RemoveCommand extends AbstractBindableCommand {

        public function RemoveCommand() {
            bindings = [
                new BindingProperties("F8"),
                new BindingProperties("Bsp"),
                new BindingProperties("Shift-F8").setParams([new Param("MOVE_TO_TRASH", false)]),
                new BindingProperties("Shift-Bsp").setParams([new Param("MOVE_TO_TRASH", false)])
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
            srcNodes = srcPanel.selection.length > 0 ? srcPanel.selection.getSelectedNodes() : [srcPanel.selectedNode];
            srcDir = srcPanel.directory;
            srcTP = srcPanel.directory.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:RemoveInitDialog = new RemoveInitDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var te:ITreeEditor = srcTP as ITreeEditor;

            removeOperation = te.remove().setNodes(srcNodes);

            p.nodesCount = srcNodes.length;
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (srcNodes.length == 1) {
                p.nodeName = INode(srcNodes[0]).name;
            }

            if (removeOperation is IParametrized) {
                for each (var bcp:IParam in context.parameters.list) {
                    // set binding context parameters as defaults
                    IParametrized(removeOperation)
                        .getParameters()
                        .param(bcp.name).value = bcp.value;
                }
                p.parameters = IParametrized(removeOperation).getParameters().list;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) { cancel() }
                else if (p.okButton == e.target) { ok() }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) { cancel() }
            }


            function ok():void {
                app.popupManager.remove(pd);
                beginRemove();
            }


            function cancel():void {
                app.popupManager.remove(pd);
                removeOperation.cancel();
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
                    removeOperation.cancel();
                    app.popupManager.remove(pd);
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
        private var removeOperation:ITreeRemoveOperation;
    }
}
