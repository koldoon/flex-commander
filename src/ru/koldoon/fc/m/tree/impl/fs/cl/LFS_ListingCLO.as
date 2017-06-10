package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.AccessDeniedMessage;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileType;
    import ru.koldoon.fc.m.tree.impl.LinkNode;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;

    /**
     * Using POSIX ls command creates nodes for a particular directory
     */
    public class LFS_ListingCLO extends CommandLineOperation implements IInteractive {

        /**
         * Capture LS output:
         *      lrwxr-xr-x   1 root  wheel      22 Oct 24 14:39:11 2016 resolv.conf -> ../var/run/resolv.conf
         *      drwxr-xr-x   2 root  wheel      68 Nov  5 01:02:14 2016 rc.d
         *      -rw-r--r--   1 root  wheel    5258 Aug 30 03:56:42 2016 rc.netboot
         *
         * Group 1: File Type
         *      b     Block special file.
         *      c     Character special file.
         *      d     Directory.
         *      l     Symbolic link.
         *      s     Socket link.
         *      p     FIFO.
         *      -     Regular file.
         * Group 2: Attributes: rwxr-xr-x
         * Group 3: File Size in bytes: 34566
         * Group 4: Month Name: Oct
         * Group 5: Date of Month: 24
         * Group 6: Hours: 14
         * Group 7: Minutes: 39
         * Group 8: Seconds: 42
         * Group 9: Year: 2016
         * Group 10: File name if a link: resolv.conf
         * Group 11: Link target: ../var/run/resolv.conf
         * Group 12: File name if NOT a link: rc.netboot
         */
        public static const LS_RXP:RegExp = /^([bcdlsp-])([srwxtTS-]{9})[@+]?\s+\d+\s+\w+\s+\w+\s+(\d+)\s+(\w{3})\s+(\d{1,2})\s+(\d{2}):(\d{2}):(\d{2})\s+(\d{4})\s+(?:(?:(.+) -> (.+))|(.+))$/;

        public static const ACCESS_DENIED:RegExp = /^ls:\s+(.*):\s+Permission denied$/;

        /**
         * Get catalog name from LS header in recursive mode
         */
        public static const DIR_RXP:RegExp = /^(\/.+):$/;

        /**
         * Get total string and value
         */
        public static const TOTAL_RXP:RegExp = /^total\s+(\d+)$/;

        public static const MONTHS:Object = {
            "Jan": 0,
            "Feb": 1,
            "Mar": 2,
            "Apr": 3,
            "May": 4,
            "Jun": 5,
            "Jul": 6,
            "Aug": 7,
            "Sep": 8,
            "Oct": 9,
            "Nov": 10,
            "Dec": 11
        };


        /**
         * Nodes created
         */
        [ArrayElementType("ru.koldoon.fc.m.tree.INode")]
        public function getNodes():Array {
            return _nodes;
        }


        /**
         * Total size of all regular file nodes in Bytes
         */
        public var sizeTotal:Number = 0;


        public function get interaction():IInteraction {
            return _interaction;
        }


        override protected function begin():void {
            command("bin/ls");
            var args:Array = ["-lT"];
            if (_followLinks) {
                args.push("-H");
            }
            if (_recursive) {
                args.push("-R");
            }
            if (_includeHiddenFiles) {
                args.push("-A");
            }
            args.push(_path);
            commandArguments(args);

            super.begin();
        }


        /**
         * Holder for current dir based on "ls" output header
         */
        private var currentDir:String;

        private var sourcePathIsDirectory:Boolean;


        override protected function onLines(lines:Array):void {
            for each (var l:String in lines) {

                var ls:Object = LS_RXP.exec(l);
                if (ls) {
                    _nodes.push(createNode(ls));
                    continue;
                }

                var dir:Object = DIR_RXP.exec(l);
                if (dir) {
                    currentDir = dir[1];
                    continue;
                }

                if (!_createReferenceNodes || sourcePathIsDirectory) {
                    // nothing to check any more.
                    // total before directory can appear for a root dir only
                    continue;
                }

                var total:Object = TOTAL_RXP.exec(l);
                if (total) {
                    sourcePathIsDirectory = true;
                    currentDir = _path;
                }
            }
        }


        private function createNode(ls:Object):FileNode {
            var ftype:int = FileType.FILE_TYPE_BY_ATTR[ls[1]];
            var attrs:String = ls[2];
            var size:Number = ls[3];
            var month:String = ls[4];
            var date:int = ls[5];
            var hh:int = ls[6];
            var mm:int = ls[7];
            var ss:int = ls[8];
            var yyyy:int = ls[9];
            var fname:String = ls[10] || ls[12];
            var link:String = ls[11];
            var node:FileNode;

            if (_createReferenceNodes || _recursive) {
                // create flat structure nodes:
                // if given source node was a single file, then ls in its output
                // prints the whole path and we don't need to concatenate is with root dir
                var ref:String = sourcePathIsDirectory ? [currentDir, fname].join("/") : fname;
                var name:String = sourcePathIsDirectory ? fname : fname.split("/").pop();
                node = new ReferenceNode(name, _node, ref);
            }
            else {
                // create normal listing structure nodes
                if (ftype == FileType.SYMBOLIC_LINK) {
                    node = new LinkNode(fname, _node, link);
                }
                else if (ftype == FileType.DIRECTORY) {
                    node = new DirectoryNode(fname, _node);
                }
                else {
                    node = new FileNode(fname, _node);
                }
            }

            node.fileType = ftype;
            node.attributes = attrs;
            node.modified = new Date(yyyy, MONTHS[month], date, hh, mm, ss);

            if (ftype == FileType.REGULAR) {
                node.size = size;
                node.executable = attrs.indexOf("x") != -1;
                sizeTotal += size;
            }

            return node;
        }


        override protected function onErrorLines(lines:Array):void {
            for each (var l:String in lines) {
                var ad:Object = ACCESS_DENIED.exec(l);
                if (ad) {
                    _interaction.setMessage(new AccessDeniedMessage(ad[1]));
                }
            }
        }


        // -----------------------------------------------------------------------------------
        // Options
        // -----------------------------------------------------------------------------------


        /**
         * Path to get listing of
         */
        public function path(p:String):LFS_ListingCLO {
            _path = p;
            return this;
        }


        /**
         * Parent node to set in created sub-nodes
         */
        public function parentNode(n:INode):LFS_ListingCLO {
            _node = n;
            return this;
        }


        /**
         * If you need to get info from the simple node that is not a directory,
         * you must set this up
         */
        public function followLinkNodes(fl:Boolean = true):LFS_ListingCLO {
            _followLinks = fl;
            return this;
        }


        /**
         * Recursively get listing for all sub-directories in one listing
         * If option is set, Reference Nodes will be always created.
         * Tree structure is not supported so far.
         */
        public function recursive(val:Boolean = true):LFS_ListingCLO {
            _recursive = val;
            return this;
        }


        /**
         * Create flat nodes references (ReferenceNode) isntead of normal file and directory nodes.
         * This is useful in search and select operations.
         */
        public function createReferenceNodes(val:Boolean = false):LFS_ListingCLO {
            _createReferenceNodes = val;
            return this;
        }


        /**
         * Include or not hidden files in listing. Default is true
         */
        public function includeHiddenFiles(value:Boolean = true):LFS_ListingCLO {
            _includeHiddenFiles = value;
            return this;
        }


        private var _includeHiddenFiles:Boolean = true;
        private var _createReferenceNodes:Boolean = false;
        private var _followLinks:Boolean = true;
        private var _node:INode;
        private var _path:String;
        private var _recursive:Boolean;
        private var _nodes:Array = [];
        private var _interaction:Interaction = new Interaction();

    }
}
