package ru.koldoon.fc.m.os {
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.utils.notEmpty;

    public class CommandLineOperation extends AbstractAsyncOperation implements IInteractive {
        private static const LOG_SPACES_TRIM_RXP:RegExp = /\s/g;

        private var _commandName:String;
        private var _commandArguments:Vector.<String>;
        private var _shutDownOnStdErr:Boolean = false;
        private var _waitForReturnOnStdOut:Boolean = true;
        private var _waitForReturnOnStdErr:Boolean = false;
        private var _exitCode:Number;

        private var incompleteStdOut:String;
        private var incompleteStdErr:String;
        private var npsi:NativeProcessStartupInfo;
        private var proc:NativeProcess;


        public function CommandLineOperation() {
            _interaction = new Interaction();
            _status.onFinish(disposeInteraction);
        }


        private function disposeInteraction(op:IAsyncOperation):void {
            _interaction.dispose();
        }


        /**
         * Interaction implementation accessor
         */
        protected var _interaction:Interaction;


        /**
         * Command exit code. Available when operation is completed.
         */
        public function get exitCode():Number {
            return _exitCode;
        }


        public function command(str:String):CommandLineOperation {
            _commandName = str;
            return this;
        }


        public function commandArguments(a:Array):CommandLineOperation {
            // Array API a little bit more compact
            var args:Vector.<String> = Vector.<String>(a);
            _commandArguments = args;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function get interaction():IInteraction {
            return _interaction;
        }


        /**
         * @inheritDoc
         */
        override public function cancel():void {
            super.cancel();
            close();
        }


        /**
         * Terminates process with SIG_TERM.
         */
        public function close():void {
            incompleteStdOut = null;
            if (proc) {
                proc.exit(true);
            }
        }


        /**
         * Do not report new line until CR is received
         * @default false
         */
        public function shutDownOnStdErr(val:Boolean):CommandLineOperation {
            _shutDownOnStdErr = val;
            return this;
        }


        /**
         * Do not report new line until CR is received from StdOut
         * @default true
         */
        public function waitForReturnOnStdOut(value:Boolean):CommandLineOperation {
            _waitForReturnOnStdOut = value;
            return this;
        }


        /**
         * Do not report new line until CR is received from StdErr
         * @default false
         */
        public function waitForReturnOnStdErr(value:Boolean):CommandLineOperation {
            _waitForReturnOnStdErr = value;
            return this;
        }



        /**
         * @inheritDoc
         */
        override protected function begin():void {
            LOG.debug("Executing: " + _commandName + " " + (_commandArguments ? _commandArguments.join(" ") : ""));
            incompleteStdOut = "";

            npsi = new NativeProcessStartupInfo();
            proc = new NativeProcess();

            try {
                npsi.workingDirectory = File.applicationDirectory.resolvePath("bin");
                npsi.executable = File.applicationDirectory.resolvePath(_commandName);
                npsi.arguments = _commandArguments;

                proc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
                proc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData);
                proc.addEventListener(NativeProcessExitEvent.EXIT, onProcessFinish);
                proc.start(npsi);
            }
            catch (error:Error) {
                LOG.error("{0} {1}\n{2}", error.name, error.message, error.getStackTrace());
                fault();
            }
        }


        private function onStandardErrorData(event:Event):void {
            var np:NativeProcess = NativeProcess(event.target);
            var listing:String = np.standardError.readUTFBytes(np.standardError.bytesAvailable);
            var lines:Array = listing.split("\n");

            if (incompleteStdErr) {
                var lostListing:String = incompleteStdErr + (lines.length > 0 ? lines.shift() : "");
                var lostLines:Array = lostListing.split("\n");
                while (lostLines.length > 0) {
                    lines.unshift(lostLines.pop());
                }
                incompleteStdOut = null;
            }

            if (_waitForReturnOnStdErr && lines.length > 0 && notEmpty(lines[lines.length - 1])) {
                incompleteStdOut = lines.pop();
            }

            if (lines.length > 0) {
                LOG.warn("Std Error Lines ({0}), the first is: \"{1}\"", lines.length, lines[0].replace(LOG_SPACES_TRIM_RXP, " "));
                onErrorLines(lines);
            }

            if (_shutDownOnStdErr) {
                np.exit(true);
                fault();
            }
        }


        private function onStandardOutputData(event:Event):void {
            var np:NativeProcess = NativeProcess(event.target);
            var listing:String = np.standardOutput.readUTFBytes(np.standardOutput.bytesAvailable);
            var lines:Array = listing.split("\n");

            if (incompleteStdOut) {
                var lostListing:String = incompleteStdOut + (lines.length > 0 ? lines.shift() : "");
                var lostLines:Array = lostListing.split("\n");
                while (lostLines.length > 0) {
                    lines.unshift(lostLines.pop());
                }
                incompleteStdOut = null;
            }

            if (_waitForReturnOnStdOut && lines.length > 0 && notEmpty(lines[lines.length - 1])) {
                incompleteStdOut = lines.pop();
            }

            if (lines.length > 0) {
                LOG.info("Std Out Lines ({0}), the first is: \"{1}\"", lines.length, lines[0].replace(LOG_SPACES_TRIM_RXP, " "));
                onLines(lines);
            }
        }


        private function onProcessFinish(event:NativeProcessExitEvent):void {
            if (status.isCanceled || status.isError) {
                return;
            }

            if (incompleteStdOut) {
                onLines(incompleteStdOut.split("\n"));
                incompleteStdOut = null;
            }

            _exitCode = event.exitCode;
            done();
        }


        /**
         * Write Line in standard input
         * @param line
         */
        public function stdInput(line:String):void {
            if (proc && proc.running) {
                proc.standardInput.writeUTFBytes(line + "\n");
            }
        }


        /**
         * Std Error lines handler
         */
        protected function onErrorLines(lines:Array):void {

        }


        /**
         * Std Out lines handler
         */
        protected function onLines(lines:Array):void {

        }
    }
}
