package ru.koldoon.fc.m.app {
    import ru.koldoon.fc.m.popups.IPopupManager;

    public interface IApplication {

        function get context():IApplicationContext;


        function get leftPanel():IPanel;
        function get rightPanel():IPanel;

        function getTargetPanel(target:String):IPanel;

        /**
         * Application level PopupManager
         * @see IPanel
         */
        function get popupManager():IPopupManager;
    }
}
