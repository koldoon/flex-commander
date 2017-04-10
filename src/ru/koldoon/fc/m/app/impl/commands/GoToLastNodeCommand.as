package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class GoToLastNodeCommand extends AbstractBindableCommand {

        public function GoToLastNodeCommand() {
            bindings = [
                new BindingProperties("Right")
            ];
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            panel.selectedNodeIndex = panel.directory.nodes.length - 1;
        }
    }
}
