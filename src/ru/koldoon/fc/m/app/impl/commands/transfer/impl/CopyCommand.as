package ru.koldoon.fc.m.app.impl.commands.transfer.impl {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.transfer.*;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;

    public class CopyCommand extends AbstractTreeTransferCommand {

        public function CopyCommand() {
            bindings = [
                new BindingProperties("F5")
            ];
        }


        override protected function onTransmitOperationFinish():void {
            var source:IPanel = app.getActivePanel();
            var target:IPanel = app.getPassivePanel();

            source.selection.reset();
            target.directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    target.refresh();
                });
        }


        override public function execute():void {
            var te:ITreeEditor =
                app.getActivePanel().directory.getTreeProvider() as ITreeEditor;

            operation = te.copy();
            operationName = "Copy";

            if (!operation) {
                LOG.warn("Operation is not supported by given TreeProvider");
                // operation is not supported
            }
            else {
                super.execute();
            }
        }

    }
}
