package ru.koldoon.fc.m.tree.impl.fs.copy {
    import mx.utils.StringUtil;

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IInteractionMessage;
    import ru.koldoon.fc.m.async.IInteractiveOperation;
    import ru.koldoon.fc.m.async.impl.InteractionMessage;
    import ru.koldoon.fc.m.async.impl.InteractionMessageType;
    import ru.koldoon.fc.m.async.impl.InteractionOption;
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LocalFileSystemCopyCommandLineOperation extends CommandLineOperation implements IInteractiveOperation {
        /**
         * Group 1: File Path to overwrite
         */
        private static const OVERWRITE_RXP:RegExp = /^overwrite\s+(.+)\?\s+\(y\/n\s\[n]\)$/;


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
            commandArguments("-i \"{0}\" \"{1}\"", _sourceFilePath, _targetFilePath);
        }


        override protected function onErrorLines(lines:Array):void {
            var o:Object = OVERWRITE_RXP.exec(lines[0]);
            if (o) {
                lastMessage = new InteractionMessage(InteractionMessageType.CONFIRMATION)
                    .setText(StringUtil.substitute("Overwrite existing file? ({0})", o[1]))
                    .responseOptions([new InteractionOption("y", "Yes"), new InteractionOption("n", "No")])
                    .onResponse(function (option:InteractionOption):void {
                        stdInput(option.value);
                        lastMessage = null;
                    });

                _onQuestion.dispatch(this);
            }
            else {
                LOG.error("Unexpected CP error: {0}", lines[0]);
                fault();
            }
        }


        // -----------------------------------------------------------------------------------
        // IInteractiveOperation
        // -----------------------------------------------------------------------------------

        public function getMessage():IInteractionMessage {
            return lastMessage;
        }


        public function onMessage(f:Function):IInteractiveOperation {
            _onQuestion.add(f);
            return this;
        }


        private var _sourceFilePath:String;
        private var _targetFilePath:String;
        private var lastMessage:InteractionMessage;
        private var _onQuestion:Signal = new Signal();
    }
}
