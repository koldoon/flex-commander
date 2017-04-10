package ru.koldoon.fc.m.tree.impl.fs.console {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemMkDirCommandLineOperation extends CommandLineOperation {

        private static const DIR_EXISTS_ERR_RXP:RegExp = /File exists/;


        override protected function begin():void {
            command("bin/mkdir");
            commandArguments(["-p", _path]);
            super.begin();
        }


        override protected function onErrorLines(lines:Array):void {
            var l:String = lines[0];
            if (DIR_EXISTS_ERR_RXP.exec(l)) {
                status.info = "Could not create directory:\nFile exists";
                fault();
            }
        }


        public function path(value:String):LocalFileSystemMkDirCommandLineOperation {
            _path = value;
            return this;
        }


        private var _path:String;
    }
}
