package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class ResetPanelSelectionCommand extends AbstractBindableCommand {
        public function ResetPanelSelectionCommand() {
            bindings = [
                new BindingProperties("Esc")
            ];
        }

        override public function execute():void {
            app.getActivePanel().selection.reset();
        }
    }
}
