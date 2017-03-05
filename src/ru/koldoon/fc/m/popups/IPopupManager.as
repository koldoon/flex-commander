package ru.koldoon.fc.m.popups {
    public interface IPopupManager {

        function add():IPopupDescriptor;

        function remove(d:IPopupDescriptor = null):void;

        function get shown():Vector.<IPopupDescriptor>;

        function get queue():Vector.<IPopupDescriptor>;

    }
}
