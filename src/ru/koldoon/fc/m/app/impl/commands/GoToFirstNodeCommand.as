package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class GoToFirstNodeCommand extends AbstractBindableCommand {

        public function GoToFirstNodeCommand() {
            bindings = [
                new BindingProperties("Left")
            ];
        }


        override public function execute():void {
            app.getActivePanel().selectedNodeIndex = 0;
        }

    }
}
