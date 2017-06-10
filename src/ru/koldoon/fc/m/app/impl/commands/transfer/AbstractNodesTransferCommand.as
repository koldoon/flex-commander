package ru.koldoon.fc.m.app.impl.commands.transfer {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.c.alert.AlertDialog;
    import ru.koldoon.fc.c.confirmation.ConfirmationDialog;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.IMessage;
    import ru.koldoon.fc.m.interactive.ISelectOptionMessage;
    import ru.koldoon.fc.m.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.progress.IProgressReporter;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodeProgressReporter;
    import ru.koldoon.fc.m.tree.INodesBatchOperation;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;

    import spark.components.Button;

    public class AbstractNodesTransferCommand extends AbstractBindableCommand {

        protected var operation:ITreeTransferOperation;

        /**
         * Move and Copy operations have the same interface. The only difference is
         * operation name. This property is used in dialog title.
         */
        protected var operationName:String;


        override public function isExecutable():Boolean {
            var panel:IPanel = app.getActivePanel();
            var nodes:Array = panel.selection.length > 0 ? panel.selection.getSelectedNodes() : [panel.selectedNode];

            if (nodes.length == 1 && (!nodes[0] || nodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            // the same directories can be different objects, so we use String representation
            // to actual comparing
            if (app.leftPanel.directory.getPath().join("/") == app.rightPanel.directory.getPath().join("/")) {
                // commonly it makes no sense to copy/move to the same dir
                return false;
            }

            return true;
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            var nodes:Array = panel.selection.length > 0 ? panel.selection.getSelectedNodes() : [panel.selectedNode];

            if (!operation) {
                throw new Error("Operation is not defined in implementation.");
            }

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
            p.source = FileNodeUtil.getPath(panel.directory);
            p.target = FileNodeUtil.getPath(app.getPassivePanel().directory);

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


        protected function onTransferOperationFinish():void {
            // Abstract Method
        }


        /**
         * Execute Copy or Move operation, show progress dialog
         */
        protected function beginTransmit():void {
            var p:TransferProgressDialog = new TransferProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var source:IPanel = app.getActivePanel();

            if (operation is IInteractive) {
                IInteractive(operation)
                    .interaction
                    .onMessage(onInteractionMessage);
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
                        p.currentItem = INode(op.nodesQueue[op.processingNodeIndex]).name;
                        p.itemsTotal = op.nodesQueue.length;
                        p.processingItemIndex = op.processingNodeIndex + 1;
                    });
            }


            p.title = operationName || "Progress";
            p.source = FileNodeUtil.getPath(source.directory);
            p.target = FileNodeUtil.getPath(app.getPassivePanel().directory);

            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            operation
                .status
                .onFinish(function (op:IAsyncOperation):void {
                    app.popupManager.remove(pd);
                    onTransferOperationFinish();
                })
                .operation
                .execute();

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


        private function onInteractionMessage(i:IInteraction):void {
            var msg:* = i.getMessage();

            if (msg is ISelectOptionMessage) {
                showConfirmationDialog(msg);
            }
            else if (msg is IMessage) {
                showAlertDialog(msg);
            }
        }


        private function showConfirmationDialog(msg:ISelectOptionMessage):void {
            var p:ConfirmationDialog = new ConfirmationDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.message = msg;
            p.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                if (e.target is Button) {
                    // Any confirmation Button was clicked
                    app.popupManager.remove(pd);
                }
            });
        }


        private function showAlertDialog(msg:IMessage):void {
            var p:AlertDialog = new AlertDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.message = msg;
            p.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                if (e.target == p.okButton) {
                    app.popupManager.remove(pd);
                }
            });
        }

    }
}
