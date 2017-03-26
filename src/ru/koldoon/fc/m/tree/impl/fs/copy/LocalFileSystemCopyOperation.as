package ru.koldoon.fc.m.tree.impl.fs.copy {
    import flash.utils.Dictionary;

    import mx.collections.ArrayList;

    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.IInteractionMessage;
    import ru.koldoon.fc.m.async.IInteractiveOperation;
    import ru.koldoon.fc.m.async.IPromise;
    import ru.koldoon.fc.m.async.impl.AsyncCollection;
    import ru.koldoon.fc.m.async.impl.InteractionMessageType;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.fs.*;
    import ru.koldoon.fc.utils.notEmpty;

    public class LocalFileSystemCopyOperation extends AbstractNodesBunchOperation {

        /**
         * @param n list of INode
         * @return
         */
        public function nodes(n:Array):LocalFileSystemCopyOperation {
            nodes_ = n;
            return this;
        }


        public function destination(d:IDirectory):LocalFileSystemCopyOperation {
            destination_ = d;
            return this;
        }


        public function source(d:IDirectory):LocalFileSystemCopyOperation {
            source_ = d;
            return this;
        }


        override protected function begin():void {
            filesReferences = new ArrayList();
            nodesTotal = 0;
            bytesTotal = 0;
            bytesProcessed = 0;
            nodesProcessed = 0;
            listings = new Dictionary();
            listingsLen = 0;

            treeProvider = destination_.getTreeProvider();

            getSourceDirPath();
            getDestinationDirPath();

            if (notEmpty(nodes_)) {
                scanForFiles(nodes_);
            }
            else {
                scanForNodes([source_]);
            }
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        /**
         * Array of FileNode (because this class is LocalFileSystemTreeProvider's delegate)
         */
        private var nodes_:Array;
        private var source_:IDirectory;
        private var sourcePath:String;
        private var destination_:IDirectory;
        private var destinationPath:String;
        private var treeProvider:ITreeProvider;
        private var filesReferences:ArrayList;
        private var listings:Dictionary;
        private var listingsLen:int;


        private function getSourceDirPath():void {
            var acn:IPromise = IFilesProvider(treeProvider)
                .getFiles([source_])
                .onReady(function (ac:IAsyncCollection):void {
                    sourcePath = ac.items[0];
                    delete listings[acn];
                    listingsLen -= 1;
                    onPreparingComplete();
                });

            listings[acn] = true;
            listingsLen += 1;
        }


        private function getDestinationDirPath():void {
            var acn:IPromise = IFilesProvider(treeProvider)
                .getFiles([destination_])
                .onReady(function (ac:IAsyncCollection):void {
                    destinationPath = ac.items[0];
                    delete listings[acn];
                    listingsLen -= 1;
                    onPreparingComplete();
                });

            listings[acn] = true;
            listingsLen += 1;
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
                    var acn:IPromise = treeProvider
                        .getListingFor(dir)
                        .onReady(onDirectoryListing);

                    listings[acn] = true;
                    listingsLen += 1;
                }
                else {
                    fileNodes.push(node);
                }
            }

            scanForFiles(fileNodes);
        }


        /**
         * Scan for files references in the list of INode recursively.
         * @param nodes list of INode, not the IDirectory
         */
        private function scanForFiles(nodes:Array):void {
            var acf:IPromise = IFilesProvider(treeProvider)
                .getFiles(nodes)
                .onReady(onFilesReferencesReady);

            listings[acf] = true;
            listingsLen += 1;
        }


        private function onDirectoryListing(ac:AsyncCollection):void {
            delete listings[ac];
            listingsLen -= 1;
            scanForNodes(ac.items);
        }


        private function onFilesReferencesReady(ac:IAsyncCollection):void {
            delete listings[ac];
            listingsLen -= 1;
            filesReferences.addAll(new ArrayList(ac.items));

            for each (var fsRef:FileSystemReference in ac.items) {
                nodesTotal += 1;
                bytesTotal += fsRef.size;
            }

            onPreparingComplete();
        }


        private function onPreparingComplete():void {
            if (listingsLen == 0) {
                copyNextFile();
            }
        }


        // -----------------------------------------------------------------------------------
        // Copy CMD
        // -----------------------------------------------------------------------------------

        private var copyOperation:IAsyncOperation;


        private function copyNextFile():void {
            if (copyOperation) {
                return;
            }

            if (nodesProcessed == nodesTotal) {
                done();
            }
            else {
                var fsRef:FileSystemReference = filesReferences.getItemAt(nodesProcessed) as FileSystemReference;
                currentNode = fsRef.node;

                copyOperation = new LocalFileSystemCopyCommandLineOperation()
                    .sourceFilePath(fsRef.path)
                    .targetFilePath(getFileTargetPath(fsRef.path))
                    .onMessage(function (op:IInteractiveOperation):void {
                        var m:IInteractionMessage = op.getMessage();
                        if (m.type == InteractionMessageType.CONFIRMATION) {
                            // show popup, ask what to do
                        }
                    })
                    .execute();

                copyOperation.status
                    .onComplete(continueCopy)
                    .onFault(function (data:Object):void {
                        // show popup, ask what to do
                    });
            }
        }


        private function continueCopy(op:IAsyncOperation):void {
            nodesProcessed += 1;
            bytesProcessed += FileNode(currentNode).size;
            copyOperation = null;
            copyNextFile();

            progress_.setPercent(nodesProcessed / nodesTotal * 100);
        }


        private function getFileTargetPath(sourceFilePath:String):String {
            return destinationPath + sourceFilePath.substr(sourcePath.length);
        }
    }
}
