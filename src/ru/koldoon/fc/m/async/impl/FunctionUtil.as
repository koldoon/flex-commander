package ru.koldoon.fc.m.async.impl {
    public class FunctionUtil {
        public static function call(func:Function, args:Array = null):void {
            if (!func) {
                return;
            }

            if (func.length == 0) {
                func();
            }
            else if (func.length == 1) {
                func(args[0]);
            }
            else if (func.length == 2) {
                func(args[0], args[1]);
            }
            else if (func.length == 3) {
                func(args[0], args[1], args[2]);
            }
        }
    }
}
