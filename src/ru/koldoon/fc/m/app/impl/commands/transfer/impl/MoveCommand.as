package ru.koldoon.fc.m.app.impl.commands.transfer.impl {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.transfer.AbstractTreeTransferCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.ITreeEditor;

    public class MoveCommand extends AbstractTreeTransferCommand {
        public function MoveCommand() {
            bindings = [
                new BindingProperties("F6")
            ];
        }


        override protected function onTransmitOperationFinish():void {
            var source:IPanel = app.getActivePanel();
            var target:IPanel = app.getPassivePanel();

            source.selection.reset();
            source.directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    source.refresh();
                });

            target.directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    target.refresh();
                });
        }


        override public function execute():void {
            var te:ITreeEditor =
                app.getActivePanel().directory.getTreeProvider() as ITreeEditor;

            operation = te.move();
            operationName = "Move";
            super.execute();
        }

    }
}
