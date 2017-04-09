package ru.koldoon.fc.m.tree.impl {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;

    /**
     * Common implementation of Directory representing directories
     * in different File System-s and Archives.
     */
    public class DirectoryNode extends FileNode implements IDirectory {
        public function DirectoryNode(parent:INode, name:String, link:String = null) {
            super(parent, name, link);
        }


        /**
         * @inheritDoc
         */
        public function get nodes():Array {
            return _nodes;
        }


        /**
         * @inheritDoc
         */
        public function getListing():ICollectionPromise {
            var tp:ITreeProvider = getTreeProvider();
            if (tp) {
                if (!listings) {
                    listings = new Dictionary();
                }
                var op:ICollectionPromise = tp.getListingFor(this);
                listings[op] = true;
                op.onReady(function (op:ICollectionPromise):void {
                    _nodes = op.items;
                    delete listings[op];
                });
                op.onReject(function (op:ICollectionPromise):void {
                    delete listings[op];
                });
                return op;
            }
            else {
                return null;
            }
        }


        private var _nodes:Array = [];
        private var listings:Dictionary;
    }
}
