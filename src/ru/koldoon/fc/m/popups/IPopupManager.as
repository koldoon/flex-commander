package ru.koldoon.fc.m.popups {
    public interface IPopupManager {

        function add():IPopupDescriptor;

        function remove(d:IPopupDescriptor = null):void;


        /**
         * Currently display popups. If modal popup is shown, some popups
         * behind may be temporary hidden.
         */
        function getPopupsVisible():Vector.<IPopupDescriptor>;


        /**
         * Popups that was queued but not shown yet
         */
        function getQueue():Vector.<IPopupDescriptor>;

    }
}
