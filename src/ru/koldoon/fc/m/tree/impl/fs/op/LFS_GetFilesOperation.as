package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.LinkNode;
    import ru.koldoon.fc.utils.notEmpty;

    public class LFS_GetFilesOperation extends AbstractAsyncOperation {

        private var _nodes:Array;
        private var _followLinks:Boolean = true;

        /**
         * list of FileSystemReference objects
         */
        public var files:Array;


        public function setNodes(n:Array):LFS_GetFilesOperation {
            _nodes = n;
            return this;
        }


        public function followLinks(value:Boolean = true):LFS_GetFilesOperation {
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
            var head:Boolean = true;

            while (p && !(p is ITreeProvider)) {
                if (p is LinkNode && (!head || _followLinks)) {
                    if (LinkNode(p).reference.charAt(0) == "/") {
                        // Root directory reference.
                        // Such a path is absolute, no further processing is needed
                        fsPath.unshift(LinkNode(p).reference.substr(1));
                        break;
                    }
                    else {
                        fsPath.unshift(LinkNode(p).reference);
                    }
                }
                else if (notEmpty(p.name) || head) {
                    fsPath.unshift(p.name);
                }

                head = false;
                p = p.parent;
            }

            // Add root "/"
            fsPath.unshift("");

            return fsPath.join("/");
        }
    }
}
