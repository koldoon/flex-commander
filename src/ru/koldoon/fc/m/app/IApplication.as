package ru.koldoon.fc.m.app {
    import flash.display.NativeMenu;

    import ru.koldoon.fc.m.popups.IPopupManager;

    public interface IApplication {

        /**
         * Get Left panel instance
         */
        function get leftPanel():IPanel;


        /**
         * Get Right panel instance
         */
        function get rightPanel():IPanel;


        /**
         * Get NativeMenu configuration instance
         */
        function get menu():NativeMenu;


        /**
         * Get Application level PopupManager
         * @see IPanel
         */
        function get popupManager():IPopupManager;


        /**
         * Context holds app configuration, user preferences, installed commands, etc.
         */
        function getContext():IApplicationContext;


        /**
         * Get panel that currently has a focus.
         * Usually its and operation SOURCE.
         */
        function getActivePanel():IPanel;


        /**
         * Helper to get passive panel instance. Although you can get it
         * by yourself with <code>getActivePanel()</code> and check if it's
         * left or right panel, this method is more convenient.
         * Usually it is used to get operation TARGET
         */
        function getPassivePanel():IPanel


    }
}
