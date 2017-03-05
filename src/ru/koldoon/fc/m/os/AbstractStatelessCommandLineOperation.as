package ru.koldoon.fc.m.os {
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;

    public class AbstractStatelessCommandLineOperation extends AbstractAsyncOperation {
        private var incompleteStreamData:String;
        private var _commandName:String;
        private var _commandArguments:Vector.<String>;
        private var npsi:NativeProcessStartupInfo;
        private var proc:NativeProcess;


        public function command(str:String):AbstractStatelessCommandLineOperation {
            _commandName = str;
            return this;
        }


        public function commandArguments(args:String):AbstractStatelessCommandLineOperation {
            _commandArguments = new <String>[args];
            return this;
        }


        override public function cancel():void {
            super.cancel();
            incompleteStreamData = null;
            proc.exit(true);
        }


        override public function execute():IAsyncOperation {
            trace("Executing: " + _commandName + " " + _commandArguments.join(" "));
            super.execute();

            incompleteStreamData = "";

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
                fault(error);
            }

            return this;
        }


        private function onStandardErrorData(event:Event):void {
            var np:NativeProcess = NativeProcess(event.target);
            var listing:String = np.standardError.readUTFBytes(np.standardError.bytesAvailable);

            np.exit(true);
            fault(listing);
        }


        private function onStandardOutputData(event:Event):void {
            var np:NativeProcess = NativeProcess(event.target);
            var listing:String = np.standardOutput.readUTFBytes(np.standardOutput.bytesAvailable);
            var lines:Array = listing.split("\n");

            if (incompleteStreamData) {
                var lostListing:String = incompleteStreamData + (lines.length > 0 ? lines.shift() : "");
                var lostLines:Array = lostListing.split("\n");
                while (lostLines.length > 0) {
                    lines.unshift(lostLines.pop());
                }
                incompleteStreamData = null;
            }

            if (lines.length > 0) {
                incompleteStreamData = lines.pop();
            }

            onLines(lines);
        }


        private function onProcessFinish(event:NativeProcessExitEvent):void {
            if (status.isCanceled || status.isFault) {
                return;
            }

            if (incompleteStreamData) {
                onLines(incompleteStreamData.split("\n"));
                incompleteStreamData = null;
            }
            done();
        }


        protected function onLines(lines:Array):void {

        }
    }
}
