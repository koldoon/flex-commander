package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.cl.utils.LFS_CLO_Lines;

    public class LFS_RemoveCLO extends CommandLineOperation implements IInteractive {

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
            if (LFS_CLO_Lines.checkAccessDeniedLines(lines, _interaction)) {
                fault();
            }
        }


        private var _path:String;
    }
}
