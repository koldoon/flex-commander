package ru.koldoon.fc.m.app.impl.commands.copy {
    import flash.utils.Dictionary;

    import mx.collections.ArrayList;

    import ru.koldoon.fc.m.async.IPromise;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AsyncCollection;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;

    /**
     * Scan given nodes list for all nodes, located in directory.
     * Result contains all nodes in all directories, and all directories - separately.
     * It is possible to get partial results with onProgress signal using
     * <code>getLastNodesPortion()</code> and <code>getLastDirectoriesPortion</code>
     */
    public class ScanForNodesOperation extends AbstractAsyncOperation {

        override protected function begin():void {
            if (!_treeProvider) {
                fault();
            }

            listingsLen = 0;
            listings = new Dictionary();
            _lastNodesPortion = [];
            _lastDirectoriesPortion = [];
            _nodes = new ArrayList();
            _directories = new ArrayList();
        }


        /**
         * Scan for sub-nodes in the list of INode recursively.
         * @param inodes list of INode
         */
        private function scanForNodes(inodes:Array):void {
            var fileNodes:Array = [];

            for each (var node:INode in inodes) {
                if (node == AbstractNode.PARENT_NODE) {
                    continue;
                }

                var dir:IDirectory = node as IDirectory;

                if (dir) {
                    var acn:IPromise = _treeProvider
                        .getListingFor(dir)
                        .onReady(onDirectoryListing);

                    listings[acn] = true;
                    listingsLen += 1;
                }
                else {
                    fileNodes.push(node);
                }
            }
        }


        private function onDirectoryListing(ac:AsyncCollection):void {
            delete listings[ac];
            listingsLen -= 1;
            scanForNodes(ac.items);
        }


        private var _treeProvider:ITreeProvider;
        private var _lastNodesPortion:Array;
        private var _lastDirectoriesPortion:Array;
        private var _nodes:ArrayList;
        private var _directories:ArrayList;
        private var listings:Dictionary;
        private var listingsLen:int;
    }
}
