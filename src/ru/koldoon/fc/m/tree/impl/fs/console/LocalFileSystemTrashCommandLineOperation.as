package ru.koldoon.fc.m.tree.impl.fs.console {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemTrashCommandLineOperation extends CommandLineOperation {

        override protected function begin():void {
            command("bin/trash");
            commandArguments([_path]);
            super.begin();
        }


        public function path(value:String):LocalFileSystemTrashCommandLineOperation {
            _path = value;
            return this;
        }


        private var _path:String;

    }
}
