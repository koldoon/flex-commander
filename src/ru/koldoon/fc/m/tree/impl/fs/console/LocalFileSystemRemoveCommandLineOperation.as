package ru.koldoon.fc.m.tree.impl.fs.console {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemRemoveCommandLineOperation extends CommandLineOperation {
        override protected function begin():void {
            command("bin/rm");
            commandArguments(["-Rf", _path]);
            super.begin();
        }


        public function path(value:String):LocalFileSystemRemoveCommandLineOperation {
            _path = value;
            return this;
        }


        private var _path:String;
    }
}
