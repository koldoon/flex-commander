package ru.koldoon.fc.m.parametrized {
    public interface IParam {

        /**
         * Not localised Parameter name. This may be a parameter ID as well -
         * in this case it would be easier to see localisation gaps.
         */
        function get name():String;


        /**
         * Parameter value any kind.
         */
        function set value(v:*):void;


        function get value():*;

    }
}
