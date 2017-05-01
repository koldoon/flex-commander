package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileType;
    import ru.koldoon.fc.m.tree.impl.LinkNode;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.utils.isEmpty;

    public class LFS_StatCLO extends CommandLineOperation {

        /**
         * stat -f "%Sp %z %Dm %N : %Y" /Users/koldoon/tmp
         * Perm Size Dame-Mod Name : Link-Target
         *
         * Output Example:
         * lrwxr-xr-x 13 1487442968 /Users/koldoon/tmp/linktofile : /etc/asl.conf
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
         * Group 3: File Size in bytes: 13
         * Group 4: Date modified (in seconds since epoch)
         * Group 5: File Name (as in command line)
         * Group 6: Link Target (if link)
         */
        private static const STAT_RXP:RegExp = /^([bcdlsp-])([srwxtTS-]{9})[@+]?\s+(\d+)\s+(\d+)\s+(\/.+)\s:\s?(.*)$/;


        override protected function begin():void {
            command("bin/stat");
            commandArguments(["-f", "%Sp %z %Dm %N : %Y", _path]);

            super.begin();
        }


        override protected function onLines(lines:Array):void {
            if (isEmpty(lines)) {
                return;
            }

            var s:Object = STAT_RXP.exec(lines[0]);
            if (s) {
                var ftype:int = FileType.FILE_TYPE_BY_ATTR[s[1]];
                var attrs:String = s[2];
                var size:Number = s[3];
                var date:Number = s[4];
                var ref:String = s[5];
                var fname:String = ref.split("/").pop();
                var link:String = s[6];
                var fnode:FileNode;

                if (_createReferenceNode) {
                    fnode = new ReferenceNode(fname, _parentNode, ref);
                }
                else {
                    // create normal listing structure nodes
                    if (ftype == FileType.SYMBOLIC_LINK) {
                        fnode = new LinkNode(fname, _parentNode, link);
                    }
                    else if (ftype == FileType.DIRECTORY) {
                        fnode = new DirectoryNode(fname, _parentNode);
                    }
                    else {
                        fnode = new FileNode(fname, _parentNode);
                    }
                }

                fnode.fileType = ftype;
                fnode.attributes = attrs;
                fnode.modified = new Date(date * 1000);

                if (ftype == FileType.REGULAR) {
                    fnode.size = size;
                    fnode.executable = attrs.indexOf("x") != -1;
                }
            }

            _node = fnode;
        }


        /**
         * Parent node for setting in newly created one
         */
        public function parentNode(n:INode):LFS_StatCLO {
            _parentNode = n;
            return this;
        }


        /**
         * Path to resolve
         */
        public function path(p:String):LFS_StatCLO {
            _path = p;
            return this;
        }


        /**
         * Create ReferenceNode for given path instead of separated
         * File/Directory/Link nodes.
         */
        public function createReferenceNode(val:Boolean):LFS_StatCLO {
            _createReferenceNode = val;
            return this;
        }


        /**
         * Result Node
         */
        public function getNode():INode {
            return _node;
        }


        private var _node:INode;
        private var _path:String;
        private var _parentNode:INode;
        private var _createReferenceNode:Boolean;
    }
}
