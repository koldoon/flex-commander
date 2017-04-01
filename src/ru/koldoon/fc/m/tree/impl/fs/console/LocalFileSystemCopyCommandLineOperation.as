package ru.koldoon.fc.m.tree.impl.fs.console {
    import mx.utils.StringUtil;

    import ru.koldoon.fc.m.async.impl.Interaction;
    import ru.koldoon.fc.m.async.impl.InteractionMessage;
    import ru.koldoon.fc.m.async.impl.InteractionMessageType;
    import ru.koldoon.fc.m.async.impl.InteractionOption;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemCopyCommandLineOperation extends CommandLineOperation implements IInteractiveOperation {
        /**
         * Group 1: File Path to overwrite
         */
        private static const OVERWRITE_RXP:RegExp = /^overwrite\s+(.+)\?\s+\(y\/n\s\[n]\)\s*$/;
        private static const NOT_OVERWRITTEN_RXP:RegExp = /not overwritten/;


        public function LocalFileSystemCopyCommandLineOperation() {
            super();

            interaction = new Interaction();
            status.onFinish(function (data:Object):void {
                interaction.dispose();
            });
        }


        public function sourceFilePath(p:String):LocalFileSystemCopyCommandLineOperation {
            _sourceFilePath = p;
            return this;
        }


        public function targetFilePath(p:String):LocalFileSystemCopyCommandLineOperation {
            _targetFilePath = p;
            return this;
        }


        override protected function begin():void {
            command("bin/cp.sh");

            var args:Array = [];
            if (!_skipExisting && !_overwriteExisting) {
                args.push("-iaR");
            }
            if (_preserveAttrs) {
                args.push("-p");
            }
            if (_overwriteExisting) {
                args.push("-f");
            }
            if (_skipExisting) {
                args.push("-n");
            }

            args.push(_sourceFilePath);
            args.push(_targetFilePath);
            commandArguments(args);

            super.begin();
        }


        override protected function onErrorLines(lines:Array):void {
            var o:Object = OVERWRITE_RXP.exec(lines[0]);
            var no:Object = NOT_OVERWRITTEN_RXP.exec(lines[0]);

            if (o) {
                interaction.setMessage(
                    new InteractionMessage(InteractionMessageType.CONFIRMATION)
                        .setText(StringUtil.substitute("Overwrite existing file?\n{0}", o[1]))
                        .responseOptions([
                            new InteractionOption("n", "Skip"),
                            new InteractionOption("y", "Overwrite")])
                        .onResponse(function (option:InteractionOption):void {
                            stdInput(option.value);
                        })
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


        public function preserveAttrs(value:Boolean):LocalFileSystemCopyCommandLineOperation {
            _preserveAttrs = value;
            return this;
        }


        public function overwriteExisting(value:Boolean):LocalFileSystemCopyCommandLineOperation {
            _overwriteExisting = value;
            return this;
        }


        public function skipExisting(value:Boolean):LocalFileSystemCopyCommandLineOperation {
            _skipExisting = value;
            return this;
        }


        public function followSymlinks(value:Boolean):LocalFileSystemCopyCommandLineOperation {
            _followSymlinks = value;
            return this;
        }


        public function getInteraction():IInteraction {
            return interaction;
        }


        private var interaction:Interaction;

        private var _sourceFilePath:String;
        private var _targetFilePath:String;

        private var _preserveAttrs:Boolean = true;
        private var _overwriteExisting:Boolean;
        private var _skipExisting:Boolean;
        private var _followSymlinks:Boolean;

    }
}
