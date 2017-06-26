package ru.koldoon.fc.m.tree.impl.fs.cl {
    import mx.utils.StringUtil;

    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.interactive.impl.InteractionOption;
    import ru.koldoon.fc.m.interactive.impl.SelectOptionMessage;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.cl.utils.LFS_CLO_Lines;

    public class LFS_MoveCLO extends CommandLineOperation implements IInteractive {

        /**
         * Group 1: File Path to overwrite
         */
        private static const OVERWRITE_RXP:RegExp = /^overwrite\s+(.+)\?\s+\(y\/n\s\[n]\)\s*$/;
        private static const NOT_OVERWRITTEN_RXP:RegExp = /not overwritten/;


        public function LFS_MoveCLO() {
            super();

            _interaction = new Interaction();
            status.onFinish(function (data:Object):void {
                _interaction.dispose();
            });
        }


        public function sourceFilePath(p:String):LFS_MoveCLO {
            _sourceFilePath = p;
            return this;
        }


        public function targetFilePath(p:String):LFS_MoveCLO {
            _targetFilePath = p;
            return this;
        }


        override protected function begin():void {
            command("bin/mv");

            var args:Array = [];
            if (!_skipExisting && !_overwriteExisting) {
                args.push("-i");
            }

            if (_skipExisting) {
                args.push("-n");
            }
            else if (_overwriteExisting) {
                args.push("-f");
            }


            args.push(_sourceFilePath);
            args.push(_targetFilePath);
            commandArguments(args);

            super.begin();
        }


        override protected function onErrorLines(lines:Array):void {
            if (LFS_CLO_Lines.checkAccessDeniedLines(lines, _interaction)) {
                fault();
                return;
            }

            var o:Object = OVERWRITE_RXP.exec(lines[0]);
            var no:Object = NOT_OVERWRITTEN_RXP.exec(lines[0]);

            if (o) {
                _interaction.setMessage(
                    new SelectOptionMessage()
                        .responseOptions([
                            new InteractionOption("n", "Skip"),
                            new InteractionOption("y", "Overwrite")])
                        .onResponse(function (option:InteractionOption):void {
                            stdInput(option.value);
                        })
                        .setText(StringUtil.substitute(
                            "Could not move: File exists.\nOverwrite existing file?\n\n{0}\n", o[1]))
                );
            }
            else if (no) {
                // ok
            }
            else {
                LOG.error("Unexpected CP error: {0}", lines[0]);
                fault();
            }
        }


        public function overwriteExisting(value:Boolean):LFS_MoveCLO {
            _overwriteExisting = value;
            return this;
        }


        public function skipExisting(value:Boolean):LFS_MoveCLO {
            _skipExisting = value;
            return this;
        }


        private var _sourceFilePath:String;
        private var _targetFilePath:String;

        private var _overwriteExisting:Boolean;
        private var _skipExisting:Boolean;
    }
}
