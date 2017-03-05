package ru.koldoon.fc.m.app.impl.commands {
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;

    public class SelectNodeCommand extends AbstractBindableCommand {
        public function SelectNodeCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("Space")
            ];
        }


        override public function isExecutable(target:String):Boolean {
            return app.getTargetPanel(target).selectedNode;
        }


        override public function execute(target:String):void {
            var panel:IPanel = app.getTargetPanel(target);
            panel.selection.invert(panel.selectedNode);
            panel.selectedNodeIndex += 1;
        }

    }
}
