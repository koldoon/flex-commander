package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.utils.notEmpty;

    public class LocalFileSystemGetFilesOperation extends AbstractAsyncOperation {

        private var _nodes:Array;
        private var _followLinks:Boolean = true;

        /**
         * list of FileSystemReference objects
         */
        public var files:Array;


        public function nodes(n:Array):LocalFileSystemGetFilesOperation {
            _nodes = n;
            return this;
        }


        public function followLinks(value:Boolean = true):LocalFileSystemGetFilesOperation {
            _followLinks = value;
            return this;
        }


        override protected function begin():void {
            files = [];
            for each (var node:INode in _nodes) {
                files.push(new FileSystemReference(getFileSystemPath(node), node));
            }
            done();
        }


        // TODO: This method can be optimized with cache
        private function getFileSystemPath(node:INode):String {
            var p:INode = node;
            var fsPath:Array = [];

            while (p && !(p is ITreeProvider)) {
                if (notEmpty(p.link) && _followLinks) {
                    if (p.link.charAt(0) == "/") {
                        // Root directory reference.
                        // Such references may occur with link nodes present in path
                        fsPath.unshift(p.link.substr(1));
                        break;
                    }
                    else {
                        fsPath.unshift(p.link);
                    }
                }
                else if (notEmpty(p.name)) {
                    fsPath.unshift(p.name);
                }

                p = p.parent;
            }

            fsPath.unshift("");

            if (node is IDirectory) {
                fsPath.push(""); // to add the last "/"
            }

            return fsPath.join("/");
        }
    }
}
