package ru.koldoon.fc.m.tree.impl.fs {
    import mx.utils.StringUtil;

    public class OperationError {
        public function OperationError(code:int, info:String) {
            this.code = code;
            this.info = info;
        }


        public static const ACCESS_DENIED:int = 10;
        public static const FILE_NOT_FOUND:int = 1;


        public var code:int;

        public var info:String;


        public function toString():String {
            return StringUtil.substitute("{0}: {1}", code, info);
        }
    }
}
