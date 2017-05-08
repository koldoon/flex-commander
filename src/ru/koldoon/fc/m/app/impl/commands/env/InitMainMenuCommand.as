package ru.koldoon.fc.m.app.impl.commands.env {
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.NativeWindowRenderMode;
    import flash.events.Event;

    import mx.events.AIREvent;

    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.impl.commands.AbstractCommand;

    import spark.components.Window;

    public class InitMainMenuCommand extends AbstractCommand {

        /**
         * Main Menu structure
         *
         * File | Edit | Commands
         *               + Make Directory
         *               + Copy
         *               + Move
         *               + Remove
         */

        override public function init(app:IApplication):Boolean {
            if (!app.menu) {
                return false;
            }

            var operationsMenu:NativeMenuItem = app.menu.addItem(new NativeMenuItem("Operations"));
            operationsMenu.submenu = new NativeMenu();

            var example:NativeMenuItem = new NativeMenuItem("Example");
            example.keyEquivalent = "e";
            example.addEventListener(Event.SELECT, example_selectHandler);
            operationsMenu.submenu.addItem(example);

            // leave command and menu handlers in memory
            return true;
        }


        private function example_selectHandler(event:Event):void {
            var w:Window = new Window();
            w.alwaysInFront = true;
            w.showStatusBar = false;
            w.renderMode = NativeWindowRenderMode.GPU;
            w.open();
            w.addEventListener(AIREvent.WINDOW_DEACTIVATE, function (e:AIREvent):void {
                w.activate();
            });
        }
    }
}
