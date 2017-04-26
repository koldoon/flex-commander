package ru.koldoon.fc.m.app.impl.commands.transfer {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.c.confirmation.ConfirmationDialog;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodeProgressReporter;
    import ru.koldoon.fc.m.tree.INodesBatchOperation;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;

    import spark.components.Button;

    public class AbstractTreeTransferCommand extends AbstractBindableCommand {

        protected var operation:ITreeTransferOperation;

        /**
         * Move and Copy operations have the same interface. The only difference is
         * operation name.
         */
        protected var operationName:String;


        override public function isExecutable():Boolean {
            var panel:IPanel = app.getActivePanel();
            var nodes:Array = panel.selection.length > 0 ? panel.selection.getSelectedNodes() : [panel.selectedNode];

            if (nodes.length == 1 && (!nodes[0] || nodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            // the same directories could be different objects, so we use String representation
            // to actual comparing
            if (app.leftPanel.directory.getNodesPath().join("/") == app.rightPanel.directory.getNodesPath().join("/")) {
                // commonly it makes no sense to copy/move to the same dir
                return false;
            }

            return true;
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            var nodes:Array = panel.selection.length > 0 ? panel.selection.getSelectedNodes() : [panel.selectedNode];

            operation
                .setSource(panel.directory)
                .setDestination(app.getPassivePanel().directory)
                .setSourceNodes(nodes);

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:TransferInitDialog = new TransferInitDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var panel:IPanel = app.getActivePanel();
            var nodes:Array = panel.selection.length > 0 ? panel.selection.getSelectedNodes() : [panel.selectedNode];

            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            p.operationName = operationName;
            p.source = TreeUtils.getPathString(panel.directory);
            p.target = TreeUtils.getPathString(app.getPassivePanel().directory);

            if (nodes.length == 1) {
                p.itemName = INode(nodes[0]).name;
            }
            else {
                p.itemsCount = nodes.length;
            }

            if (operation is IParametrized) {
                p.parameters = IParametrized(operation).getParameters().list;
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
                beginTransmit();
            }


            function cancel():void {
                app.popupManager.remove(pd);
                operation.cancel();
            }
        }


        protected function onTransmitOperationFinish():void {
            // Abstract Method
        }


        /**
         * Execute Copy or Move operation, show progress dialog
         */
        protected function beginTransmit():void {
            var p:TransferProgressDialog = new TransferProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var source:IPanel = app.getActivePanel();

            operation
                .execute()
                .status
                .onFinish(function (op:IAsyncOperation):void {
                    app.popupManager.remove(pd);
                    onTransmitOperationFinish();
                });


            if (operation is IInteractiveOperation) {
                IInteractiveOperation(operation)
                    .getInteraction()
                    .onMessage(onConfirmationMessage);
            }

            if (operation is IProgressReporter) {
                p.percentCompleted = 0;
                IProgressReporter(operation)
                    .progress
                    .onProgress(function (op:IProgressReporter):void {
                        p.message = op.progress.message;
                        p.percentCompleted = op.progress.percent;
                    });
            }

            if (operation is INodeProgressReporter) {
                p.currentItemPercentCompleted = 0;
                INodeProgressReporter(operation)
                    .processingNodeProgress
                    .onProgress(function (op:INodeProgressReporter):void {
                        p.currentItemPercentCompleted = op.processingNodeProgress.percent;
                    });
            }

            if (operation is INodesBatchOperation) {
                INodesBatchOperation(operation)
                    .progress
                    .onProgress(function (op:INodesBatchOperation):void {
                        p.currentItem = TreeUtils.getPathString(op.nodesQueue[op.processingNodeIndex]);
                        p.itemsTotal = op.nodesQueue.length;
                        p.processingItemIndex = op.processingNodeIndex + 1;
                    });
            }

            p.source = TreeUtils.getPathString(source.directory);
            p.target = TreeUtils.getPathString(app.getPassivePanel().directory);

            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) { cancel() }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) { cancel() }
            }


            function cancel():void {
                operation.cancel();
                app.popupManager.remove(pd);
            }
        }


        private function onConfirmationMessage(i:IInteraction):void {
            var p:ConfirmationDialog = new ConfirmationDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.message = i.getMessage();

            p.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                if (e.target is Button) {
                    // Any confirmation Button was clicked
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

    }
}
