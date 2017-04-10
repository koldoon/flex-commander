package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class SelectNodeCommand extends AbstractBindableCommand {
        public function SelectNodeCommand() {
            bindings = [
                new BindingProperties("Space")
            ];
        }


        override public function isExecutable():Boolean {
            return app.getActivePanel().selectedNode;
        }


        override public function execute():void {
            var panel:IPanel = app.getActivePanel();
            panel.selection.invert(panel.selectedNode);
            panel.selectedNodeIndex += 1;
        }

    }
}
