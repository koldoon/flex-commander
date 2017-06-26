package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.AccessDeniedMessage;
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_TrashCLO extends CommandLineOperation implements IInteractive {
        public static const ACCESS_DENIED:RegExp = /^“(.*)” couldn’t be moved to the trash because you don’t have permission to access it\.$/;


        override protected function begin():void {
            command("bin/trash");
            commandArguments([_path]);
            super.begin();
        }


        public function setPath(value:String):LFS_TrashCLO {
            _path = value;
            return this;
        }


        /**
         * @inheritDoc
         */
        override protected function onErrorLines(lines:Array):void {
            var err:Object = ACCESS_DENIED.exec(lines[0]);
            if (err) {
                _interaction.setMessage(new AccessDeniedMessage(err[1]));
                fault();
            }
        }


        private var _path:String;
    }
}
