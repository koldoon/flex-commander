package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class SaveSettingsCommand extends AbstractBindableCommand {
        public function SaveSettingsCommand() {
            bindings = [
                new BindingProperties("F2")
            ];
        }


        override public function execute():void {
            trace(JSON.stringify(app.getActivePanel().directory.getPath(), null, 4));
        }
    }
}
