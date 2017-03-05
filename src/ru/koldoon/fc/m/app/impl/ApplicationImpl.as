package ru.koldoon.fc.m.app.impl {
    import flash.events.KeyboardEvent;

    import ru.koldoon.fc.Main;
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.IApplicationContext;
    import ru.koldoon.fc.m.app.IBindable;
    import ru.koldoon.fc.m.app.ICommand;
    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.popups.IPopupManager;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.utils.isEmpty;

    public class ApplicationImpl implements IApplication {
        public function ApplicationImpl() {
            context_ = new ApplicationContext(this);
        }


        /**
         * @inheritDoc
         */
        public function get context():IApplicationContext {
            return context_;
        }


        /**
         * @inheritDoc
         */
        public function get leftPanel():IPanel {
            return view.leftPanel;
        }


        /**
         * @inheritDoc
         */
        public function get rightPanel():IPanel {
            return view.rightPanel;
        }


        /**
         * @inheritDoc
         */
        public function getTargetPanel(target:String):IPanel {
            if (target == ExecutionTarget.ACTIVE_PANEL) {
                return leftPanel.selectedNodeIndex != -1 ? leftPanel : rightPanel;
            }
            else if (target == ExecutionTarget.LEFT_PANEL) {
                return leftPanel;
            }
            else if (target == ExecutionTarget.RIGHT_PANEL) {
                return rightPanel;
            }
            return null;
        }


        /**
         * @inheritDoc
         */
        public function get popupManager():IPopupManager {
            return view.popupManager;
        }


        public function attachView(main:Main):void {
            view = main;
            view.leftPanel.addEventListener(KeyboardEvent.KEY_DOWN, onPanelKeyPress);
            view.rightPanel.addEventListener(KeyboardEvent.KEY_DOWN, onPanelKeyPress);
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        private var context_:ApplicationContext;
        private var view:Main;


        /**
         * Main keyboard events handling Loop
         * @param event
         */
        private function onPanelKeyPress(event:KeyboardEvent):void {
            var combination:String = BindingProperties.detectCombination(event);
            if (isEmpty(combination)) {
                return;
            }

            for each (var cmd:ICommand in context_.commandsInstalled) {
                if (!(cmd is IBindable)) {
                    continue;
                }

                for each (var bp:BindingProperties in IBindable(cmd).bindingProperties) {
                    if (bp.keysCombination != combination) {
                        continue;
                    }

                    if (bp.nodeValue && cmd.isExecutable(bp.executionTarget)) {
                        var node:INode = getTargetPanel(bp.executionTarget).selectedNode;
                        if (node && bp.nodeValue.exec(node.value)) {
                            cmd.execute(bp.executionTarget);
                            return;
                        }
                    }
                    else if (cmd.isExecutable(bp.executionTarget)) {
                        cmd.execute(bp.executionTarget);
                        return;
                    }
                }
            }
        }
    }
}
