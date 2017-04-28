package ru.koldoon.fc.m.app.impl.commands.startup {
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.events.Event;

    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.impl.commands.AbstractCommand;

    public class InitMainMenuCommand extends AbstractCommand {

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
            trace("Example Selected");
        }
    }
}
