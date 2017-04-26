package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_TestCLO extends CommandLineOperation {

        override protected function begin():void {
            command("bin/test");
            commandArguments(["-e", _path]);
            super.begin();
        }


        public function path(value:String):LFS_TestCLO {
            _path = value;
            return this;
        }


        private var _path:String;
    }
}
