package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class GoToLastNodeCommand extends AbstractBindableCommand {

        public function GoToLastNodeCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("Right")
            ];
        }


        override public function execute(target:String):void {
            var panel:IPanel = app.getTargetPanel(target);
            panel.selectedNodeIndex = panel.directory.nodes.length - 1;
        }
    }
}
