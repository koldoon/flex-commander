package ru.koldoon.fc.c.windows {
    import mx.events.FlexNativeWindowBoundsEvent;

    import spark.components.Window;

    public class DialogWindow extends Window {
        public function DialogWindow() {
            renderMode = "gpu";
            resizable = false;
            showStatusBar = false;
            minimizable = false;
            maximizable = false;

            addEventListener(FlexNativeWindowBoundsEvent.WINDOW_MOVE, windowMoveHandler);
        }


        private function windowMoveHandler(event:FlexNativeWindowBoundsEvent):void {
            event.stopImmediatePropagation();
        }
    }
}
