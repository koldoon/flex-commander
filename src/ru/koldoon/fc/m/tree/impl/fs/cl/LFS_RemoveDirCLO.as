package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_RemoveDirCLO extends CommandLineOperation {
        override protected function begin():void {
            command("bin/rmdir");
            commandArguments([_path]);
            super.begin();
        }


        public function setPath(value:String):LFS_RemoveDirCLO {
            _path = value;
            return this;
        }


        private var _path:String;
    }
}
