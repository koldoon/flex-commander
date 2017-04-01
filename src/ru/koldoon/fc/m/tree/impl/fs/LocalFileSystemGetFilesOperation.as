package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.utils.notEmpty;

    public class LocalFileSystemGetFilesOperation extends AbstractAsyncOperation {

        private var nodes_:Array;

        /**
         * list of FileSystemReference objects
         */
        public var files:Array;


        public function nodes(n:Array):LocalFileSystemGetFilesOperation {
            nodes_ = n;
            return this;
        }


        override protected function begin():void {
            files = [];
            for each (var node:INode in nodes_) {
                files.push(new FileSystemReference(getFileSystemPath(node), node));
            }
            done();
        }

        // TODO: This method can be optimized with cache
        private function getFileSystemPath(node:INode):String {
            var p:INode = node;
            var fsPath:Array = [];

            while (p && !(p is ITreeProvider)) {
                if (notEmpty(p.value)) {
                    if (p.value.charAt(0) == "/") {
                        // Root directory reference.
                        // Such references may occur with link nodes present in path
                        fsPath.unshift(p.value.substr(1));
                        break;
                    }
                    else {
                        fsPath.unshift(p.value);
                    }
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
