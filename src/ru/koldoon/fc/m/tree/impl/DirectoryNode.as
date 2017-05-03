package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;

    /**
     * Common implementation of IDirectory representing directories
     * in different File System-s
     */
    public class DirectoryNode extends FileNode implements IDirectory {
        public function DirectoryNode(name:String = null, parent:INode = null) {
            super(name, parent);
        }


        /**
         * @inheritDoc
         */
        public function get nodes():Array {
            return _nodes;
        }


        public function setNodes(value:Array):void {
            _nodes = value;
        }


        /**
         * @inheritDoc
         */
        public function refresh():IAsyncOperation {
            return getTreeProvider().getDirectoryListing(this);
        }


        private var _nodes:Array = [];
    }
}
