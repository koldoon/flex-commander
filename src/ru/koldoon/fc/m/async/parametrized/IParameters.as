package ru.koldoon.fc.m.async.parametrized {
    public interface IParameters {

        /**
         * List of all params
         * @see ru.koldoon.fc.m.async.parametrized.IParam
         */
        function get list():Array;


        /**
         * Param by name accessor
         * @param name
         * @return
         */
        function param(name:String):IParam;

        /**
         * Set given parameters values.
         * @param params array of IParam
         */
        function setup(params:Array):void;

    }
}
