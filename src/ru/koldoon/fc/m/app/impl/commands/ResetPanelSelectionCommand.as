package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class ResetPanelSelectionCommand extends AbstractBindableCommand {
        public function ResetPanelSelectionCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("Esc")
            ];
        }

        override public function execute(target:String):void {
            app.getTargetPanel(target).selection.reset();
        }
    }
}
