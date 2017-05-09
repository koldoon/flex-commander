package ru.koldoon.fc.m.app.impl.commands.env {
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.NativeWindowRenderMode;
    import flash.events.Event;

    import mx.events.AIREvent;

    import ru.koldoon.fc.c.windows.DialogWindow;
    import ru.koldoon.fc.m.app.IApplication;
    import ru.koldoon.fc.m.app.impl.commands.AbstractCommand;

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
//            var nvo:NativeWindowInitOptions = new NativeWindowInitOptions();
//            nvo.systemChrome = NativeWindowSystemChrome.STANDARD;
//            nvo.type = NativeWindowType.NORMAL;
//            nvo.renderMode = NativeWindowRenderMode.GPU;
//            nvo.owner = FlexGlobals.topLevelApplication.stage.nativeWindow;
//
//            var nv:NativeWindow = new NativeWindow(nvo);
//            nv.activate();
//
//            var tpd:TransferPrepareDialog = new TransferPrepareDialog();
//            nv.stage.addChild(tpd);

            var w:DialogWindow = new DialogWindow();
            w.width = 600;
            w.height = 400;
            w.title = "Example Window";
            w.renderMode = NativeWindowRenderMode.GPU;
            w.open();
            w.addEventListener(AIREvent.WINDOW_DEACTIVATE, function (e:AIREvent):void {
                w.activate();
            });
        }
    }
}
