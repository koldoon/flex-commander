package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.OperationError;

    public class LFS_RemoveCLO extends CommandLineOperation {
        public static const ACCESS_DENIED:RegExp = /^rm:\s+(.*):\s+Permission denied$/;


        override protected function begin():void {
            command("bin/rm");
            commandArguments(["-Rf", _path]);
            super.begin();
        }


        public function setPath(value:String):LFS_RemoveCLO {
            _path = value;
            return this;
        }


        override protected function onErrorLines(lines:Array):void {
            var err:Object = ACCESS_DENIED.exec(lines[0]);
            if (err) {
                status.info = new OperationError(OperationError.ACCESS_DENIED, err[1]);
                close();
                fault();
            }
        }


        private var _path:String;
    }
}
