package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Message;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.cl.utils.LFS_CLO_Lines;

    public class LFS_MakeDirCLO extends CommandLineOperation implements IInteractive {

        private static const DIR_EXISTS_ERR_RXP:RegExp = /File exists/;


        override protected function begin():void {
            command("bin/mkdir");
            commandArguments(["-p", _path]);
            super.begin();
        }


        override protected function onErrorLines(lines:Array):void {
            if (LFS_CLO_Lines.checkAccessDeniedLines(lines, _interaction)) {
                fault();
            }
            else {
                var ex:Object = DIR_EXISTS_ERR_RXP.exec(lines[0]);
                if (ex) {
                    _interaction.setMessage(new Message().setText("Could not create directory:\nFile exists"));
                    fault();
                }
            }
        }


        public function path(value:String):LFS_MakeDirCLO {
            _path = value;
            return this;
        }


        public function getPath():String {
            return _path;
        }


        private var _path:String;
    }
}
