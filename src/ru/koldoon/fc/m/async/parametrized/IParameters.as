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
    }
}
