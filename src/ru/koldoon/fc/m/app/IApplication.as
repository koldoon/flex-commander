package ru.koldoon.fc.m.app {
    import flash.display.NativeMenu;

    import ru.koldoon.fc.m.popups.IPopupManager;

    public interface IApplication {

        function getContext():IApplicationContext;
        function getTargetPanel(target:String):IPanel;
        function getActivePanel():IPanel;

        function get leftPanel():IPanel;
        function get rightPanel():IPanel;
        function get menu():NativeMenu;

        /**
         * Application level PopupManager
         * @see IPanel
         */
        function get popupManager():IPopupManager;
    }
}
