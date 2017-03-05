package ru.koldoon.fc.m.tree.impl {
    import mx.collections.ArrayCollection;

    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;

    /**
     * Common implementation of Directory representing directories
     * in different File System-s and Archives.
     */
    public class DirectoryNode extends FileNode implements IDirectory {
        public function DirectoryNode(parent:INode, value:String, label:String = null) {
            super(parent, value, label);
        }


        /**
         * @inheritDoc
         */
        public function get nodes():ArrayCollection {
            return nodes_;
        }


        /**
         * @inheritDoc
         */
        public function getListing():IAsyncCollection {
            var tp:ITreeProvider = getTreeProvider();
            if (tp) {
                var op:IAsyncCollection = tp.getListingFor(this);
                op.onReady(function (op:IAsyncCollection):void {
                    nodes_.list = op.items;
                });
                return op;
            }
            else {
                return null;
            }
        }


        private var nodes_:ArrayCollection = new ArrayCollection();
    }
}
