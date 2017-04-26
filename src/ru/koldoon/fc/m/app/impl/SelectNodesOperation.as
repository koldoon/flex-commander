package ru.koldoon.fc.m.app.impl {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.IPromise;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.async.impl.Progress;
    import ru.koldoon.fc.m.async.progress.IProgress;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeSelector;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;

    /**
     * Scan given nodes list for all nodes, located in directory.
     * Result contains all nodes in all directories, and all directories - separately.
     * It is possible to get partial results with onProgress signal using
     * <code>getLastNodesPortion()</code> and <code>getLastDirectoriesPortion</code>
     *
     * With default settings this operation returns a list of given source nodes
     */
    public class SelectNodesOperation extends AbstractAsyncOperation implements IProgressReporter, ITreeSelector {
        public static var MAX_LISTINGS:int = 20;


        /**
         * @inheritDoc
         */
        public function progress():IProgress {
            return progress;
        }


        /**
         * RESULT nodes list
         */
        public function get nodes():Array {
            return _nodes;
        }


        /**
         * Initial Nodes list to go through recursively
         */
        public function sourceNodes(value:Array):SelectNodesOperation {
            _sourceNodes = value;
            return this;
        }


        /**
         * Go into DirectoryNode if it has a <code>link</code> flag set
         * NOTE: option <code>recursive<code> must also be set.
         */
        public function followLinks(fl:Boolean = true):SelectNodesOperation {
            _followLinks = fl;
            return this;
        }


        /**
         * Go into directories recursively
         */
        public function recursive(r:Boolean = true):SelectNodesOperation {
            _recursive = r;
            return this;
        }


        /**
         * Filter function for nodes
         * function f(node:INode):Boolean
         */
        public function filter(f:Function):void {
            _filter = f;
        }


        /**
         * Listing operations ITreeProvider instance.
         * For the most cases this is a source directory TreeProvider.
         */
        public function treeProvider(value:ITreeProvider):SelectNodesOperation {
            _treeProvider = value;
            return this;
        }


        override protected function begin():void {
            if (!_treeProvider || !_sourceNodes) {
                fault();
            }

            listingsLen = 0;
            listings = new Dictionary();
            progress.setPercent(0, this);
            scanForNodes(_sourceNodes);
        }


        override public function cancel():void {
            for (var pr:* in listings) {
                IPromise(pr).reject();
            }
            super.cancel();
        }


        /**
         * Scan for sub-nodes in the list of INode recursively.
         * @param inodes list of INode
         */
        private function scanForNodes(inodes:Array):void {
            for each (var node:INode in inodes) {
                if (node == AbstractNode.PARENT_NODE) {
                    continue;
                }

                if (_filter != null && !_filter(node)) {
                    continue;
                }

                nodes.push(node);

                var dir:IDirectory = node as IDirectory;
                var linkToDir:Boolean = dir is DirectoryNode && DirectoryNode(dir).link;

                if (dir && _recursive && (!linkToDir || _followLinks)) {
                    if (listingsLen <= MAX_LISTINGS) {
                        getListingFor(dir);
                    }
                    else {
                        directoriesQueue.push(dir);
                    }

                    totalListingsCreated += 1;
                }
            }

            progress.setPercent(Math.max(totalListingsFinished / totalListingsCreated * 100, progress.percent), this);
            if (listingsLen == 0) {
                done();
            }
        }


        private function getListingFor(dir:IDirectory):void {
            var acn:IPromise = _treeProvider
                .getDirectoryListing(dir)
                .onReady(onDirectoryListingReady);

            listings[acn] = true;
            listingsLen += 1;
        }


        private function onDirectoryListingReady(ac:CollectionPromise):void {
            delete listings[ac];
            listingsLen -= 1;
            totalListingsFinished += 1;
            scanForNodes(ac.items);

            if (listingsLen <= MAX_LISTINGS && directoriesQueue.length > 0) {
                getListingFor(directoriesQueue.shift());
            }
        }



        private var _sourceNodes:Array;
        private var _treeProvider:ITreeProvider;
        private var _followLinks:Boolean = false;
        private var _recursive:Boolean = false;
        private var _filter:Function;
        private var _nodes:Array = [];

        private var progress:Progress = new Progress();

        private var listings:Dictionary;
        private var listingsLen:int;
        private var directoriesQueue:Vector.<IDirectory> = new <IDirectory>[];

        private var totalListingsCreated:int;
        private var totalListingsFinished:int;

    }
}
