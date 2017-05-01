package ru.koldoon.fc.m.app.impl {
    import flash.desktop.NativeApplication;
    import flash.display.NativeMenu;
    import flash.display.NativeWindow;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

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
            context = new ApplicationContext(this);
        }


        /**
         * @inheritDoc
         */
        public function getContext():IApplicationContext {
            return context;
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


        public function get menu():NativeMenu {
            var menu:NativeMenu;
            if (NativeWindow.supportsMenu) {
                if (!view.stage.nativeWindow.menu) {
                    view.stage.nativeWindow.menu = new NativeMenu();
                }

                menu = view.stage.nativeWindow.menu;
            }
            else if (NativeApplication.supportsMenu) {
                menu = NativeApplication.nativeApplication.menu;
            }

            return menu;
        }


        /**
         * @inheritDoc
         */
        public function getTargetPanel(target:String):IPanel {
            if (target == ExecutionTarget.ACTIVE_PANEL) {
                return getActivePanel();
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
        public function getActivePanel():IPanel {
            return leftPanel.active ? leftPanel : rightPanel;
        }


        /**
         * @inheritDoc
         */
        public function getPassivePanel():IPanel {
            return leftPanel.active ? rightPanel : leftPanel;
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
            view.leftPanel.addEventListener(MouseEvent.MOUSE_DOWN, onPanelMouseDown);
            view.rightPanel.addEventListener(KeyboardEvent.KEY_DOWN, onPanelKeyPress);
            view.rightPanel.addEventListener(MouseEvent.MOUSE_DOWN, onPanelMouseDown);

            // one of the panels are always active
            if (!leftPanel.active && !rightPanel.active) {
                changeActivePanel(leftPanel);
            }

            view.stage.nativeWindow.addEventListener(Event.CLOSING, onApplicationClosing);
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private var context:ApplicationContext;
        private var view:Main;


        private function onPanelMouseDown(event:MouseEvent):void {
            changeActivePanel(event.currentTarget as IPanel);
        }


        private function changeActivePanel(toPanel:IPanel = null):void {
            if (!toPanel) {
                toPanel = !leftPanel.active ? leftPanel : rightPanel;
            }

            if (!toPanel.active) {
                if (toPanel == leftPanel) {
                    leftPanel.active = true;
                    rightPanel.active = false;
                }
                else {
                    leftPanel.active = false;
                    rightPanel.active = true;
                }
            }
        }


        /**
         * Main keyboard events handling Loop
         * @param event
         */
        private function onPanelKeyPress(event:KeyboardEvent):void {
            if (event.keyCode == Keyboard.TAB) {
                changeActivePanel();
                return;
            }

            var combination:String = BindingProperties.detectCombination(event);
            if (isEmpty(combination)) {
                return;
            }

            for each (var cmd:ICommand in context.commandsInstalled) {
                if (!(cmd is IBindable)) {
                    continue;
                }

                for each (var bp:BindingProperties in IBindable(cmd).bindings) {
                    if (bp.keysCombination != combination) {
                        continue;
                    }

                    if (bp.nodeValue) {
                        var node:INode = getTargetPanel(bp.executionTarget).selectedNode;
                        if (node && !bp.nodeValue.exec(node.name)) {
                            continue;
                        }
                    }

                    IBindable(cmd).context = bp;

                    if (cmd.isExecutable()) {
                        cmd.execute();
                        return;
                    }
                }
            }
        }


        private function onApplicationClosing(event:Event):void {
            for each (var cmd:ICommand in context.commandsInstalled) {
                cmd.dispose();
            }
        }
    }
}
