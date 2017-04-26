package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_RSyncCLO extends CommandLineOperation {

        override protected function begin():void {
            command("bin/rsync");

            var args:Array = ["-av --progress"];
            if (_deleteSources) {
                args.push("--remove-source-files");
            }
            if (_dryRun) {
                args.push("-n");
            }
            if (_interactive) {
                args.push("--files-from=-");
            }
            args.push(_source);
            args.push(_destination);
            commandArguments(args);

            super.begin();
        }


        /**
         * Perform dry run - only gets the files to copy without actual
         * transferring.
         * Default is false.
         */
        public function dryRun(value:Boolean = true):LFS_RSyncCLO {
            _dryRun = value;
            return this;
        }


        /**
         * Delete source files.
         * NOTE: Empty directories won't be deleted. This is Rsync issue.
         * Default value is false.
         */
        public function deleteSources(value:Boolean = true):LFS_RSyncCLO {
            _deleteSources = value;
            return this;
        }


        /**
         * Execute rsync in interactive mode, when you need to put every
         * file in stdin to process.
         */
        public function interactive(value:Boolean):LFS_RSyncCLO {
            _interactive = value;
            return this;
        }


        /**
         * Source path (File or a Directory)
         */
        public function source(value:String):LFS_RSyncCLO {
            _source = value;
            return this;
        }


        /**
         * Destination directory path
         */
        public function destination(value:String):LFS_RSyncCLO {
            _destination = value;
            return this;
        }


        private var _source:String;
        private var _destination:String;
        private var _dryRun:Boolean = false;
        private var _deleteSources:Boolean = false;
        private var _interactive:Boolean = false;
    }
}
