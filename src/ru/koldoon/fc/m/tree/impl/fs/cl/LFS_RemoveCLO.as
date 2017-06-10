package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.AccessDeniedMessage;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_RemoveCLO extends CommandLineOperation implements IInteractive {
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
                _interaction.setMessage(new AccessDeniedMessage(err[1]));
                close();
                fault();
            }
        }


        /**
         * @inheritDoc
         */
        public function get interaction():IInteraction {
            return _interaction;
        }


        private var _path:String;
        private var _interaction:Interaction = new Interaction();
    }
}
