package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.transfer.TransferProgressDialog;

    public class SaveSettingsCommand extends AbstractBindableCommand {
        public function SaveSettingsCommand() {
            bindings = [
                new BindingProperties("F2")
            ];
        }


        override public function execute():void {
            app.popupManager.add().instance(new TransferProgressDialog());
        }
    }
}
