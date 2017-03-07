package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.os.AbstractStatelessCommandLineOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.utils.notEmpty;

    public class LocalFileSystemDirectoryListingOperation extends AbstractStatelessCommandLineOperation {
        /**
         * Detects "total" string in ls listing (usually on the first place)
         */
        public static const TOTAL_RXP:RegExp = /^total\s[0-9]*$/;

        /**
         * Detects strings of "gfind {0} -maxdepth 1 -printf '%y\t%Y\t%m\t%s\t%T@\t%p\t%l\n' listing.
         * Look into bin/listing.sh file for details.
         *
         * Group 1: File Type (dlfU)
         * Group 2: Link Target Type (dlfU)
         * Group 3: File Permissions (drwxrwxr-t)
         * Group 4: File Size in Bytes
         * Group 5: File Modification Date/Time in unix time - seconds from 1970 (1487534224.0000000000)
         * Group 6: File Name
         * Group 7: Link target
         */
        public static const FILE_RXP:RegExp = /^([dlfsU])\t([dlfsU])\t([drwxlts-]{10})\t(\d+)\t(\d+\.\d+)\t(.+)\t(.+)?$/;

        /**
         * Files Fetched
         */
        [ArrayElementType("ru.koldoon.fc.m.tree.impl.FileNode")]
        public var files:Array;


        private var directory_:IDirectory;


        public function directory(p:IDirectory):LocalFileSystemDirectoryListingOperation {
            directory_ = p;
            return this;
        }


        override public function execute():IAsyncOperation {
            // getting actual path using common interface method
            IFilesProvider(directory_.getTreeProvider())
                .getFiles([directory_])
                .onReady(onFilesReferencesReady);

            return this;
        }


        /**
         * Begin directory listing.
         */
        private function onFilesReferencesReady(ac:IAsyncCollection):void {
            command("bin/listing.sh");
            commandArguments(FileSystemReference(ac.items[0]).path);

            files = [];
            if (directory_.getParentDirectory()) {
                // Special Anchor for navigation
                files.push(AbstractNode.PARENT_NODE);
            }

            super.execute();
        }


        /**
         * Parse stdout lines and create files and directories nodes
         */
        override protected function onLines(lines:Array):void {
            if (notEmpty(lines.length) && lines[0].match(TOTAL_RXP)) {
                lines.shift();
            }

            for each (var str:String in lines) {
                var file:Object = FILE_RXP.exec(str);
                if (!file) {
                    continue;
                }

                var f:FileNode;

                if (file[2] == "d") {
                    f = new DirectoryNode(directory_, file[7] || file[6], file[6]);
                }
                else {
                    f = new FileNode(directory_, file[7] || file[6], file[6]);
                }

                f.executable = file[2] != "d" && file[3].indexOf("x") != -1;
                f.link = (file[1] == "l");
                f.attributes = file[3];
                f.size = (file[2] == "d") ? -1 : file[4];
                f.modified = new Date(1000 * file[5]);
                files.push(f);
            }

            progress();
        }
    }
}
