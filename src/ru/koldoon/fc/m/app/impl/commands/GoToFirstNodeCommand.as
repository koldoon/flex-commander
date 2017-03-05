package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class GoToFirstNodeCommand extends AbstractBindableCommand {

        public function GoToFirstNodeCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("Left")
            ];
        }


        override public function execute(target:String):void {
            app.getTargetPanel(target).selectedNodeIndex = 0;
        }

    }
}
