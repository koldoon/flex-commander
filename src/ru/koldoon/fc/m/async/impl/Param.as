package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.parametrized.IParam;

    /**
     * Basic implementation of IParam
     */
    public class Param implements IParam {

        public function Param(name:String, value:* = null) {
            _name = name;
            _value = value;
        }


        public function get name():String {
            return _name;
        }


        public function set value(v:*):void {
            _value = v;
        }


        public function get value():* {
            return _value;
        }


        private var _value:*;
        private var _name:String;

    }
}
