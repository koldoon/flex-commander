package ru.koldoon.fc.m.tree.impl.fs.console {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemMkDirCommandLineOperation extends CommandLineOperation {

        override protected function begin():void {
            command("bin/mkdir.sh");
            commandArguments(["-p", _path]);
            super.begin();
        }


        public function path(value:String):LocalFileSystemMkDirCommandLineOperation {
            _path = value;
            return this;
        }


        private var _path:String;
    }
}
