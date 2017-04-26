package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Interaction;
    import ru.koldoon.fc.m.async.impl.InteractionMessage;
    import ru.koldoon.fc.m.async.impl.InteractionOption;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.impl.Parameters;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.FileType;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_ListingCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MoveCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_RemoveDirCLO;
    import ru.koldoon.fc.utils.notEmpty;

    public class LFS_MoveOperation extends AbstractNodesBunchOperation implements IInteractiveOperation, IParametrized, ITreeTransferOperation {
        public static const OVERWRITE_ALL:String = "OVERWRITE_ALL";
        public static const SKIP_ALL:String = "SKIP_ALL";


        public function LFS_MoveOperation() {
            parameters.setup([
                new Param(SKIP_ALL, false)
            ]);

            interaction.onMessage(onInteractionMessage);
        }


        /**
         * @inheritDoc
         */
        public function setSourceNodes(list:Array):ITreeTransferOperation {
            sourceNodes = list;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function setSource(d:IDirectory):ITreeTransferOperation {
            source = d;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function setDestination(d:IDirectory):ITreeTransferOperation {
            destination = d;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function getParameters():IParameters {
            return parameters;
        }


        /**
         * @inheritDoc
         */
        public function getInteraction():IInteraction {
            return interaction;
        }


        override protected function begin():void {
            sourcePath = FileNodeUtil.getFileSystemPath(source);
            destinationPath = FileNodeUtil.getFileSystemPath(destination);

            listingIndex = 0;
            _nodesQueue = [];
            getNextListing()
        }


        private var source:IDirectory;
        private var destination:IDirectory;
        private var sourceNodes:Array;

        private var sourcePath:String;
        private var destinationPath:String;

        private var parameters:Parameters = new Parameters();
        private var interaction:Interaction = new Interaction();

        private var listingOp:IAsyncOperation;
        private var listingIndex:Number;


        private function getNextListing():void {
            var n:INode = sourceNodes[listingIndex];

            // Add source directories to remove queue
            if (n is IDirectory) {
                dirsToRemoveQueue.push(new ReferenceNode(n.name, null, FileNodeUtil.getFileSystemPath(n)))
            }

            listingOp = new LFS_ListingCLO()
                .node(n)
                .followLinkNodes(false)
                .recursive(true)
                .createFlatReferences(true)
                .execute();

            listingOp.status
                .onFinish(onListingComplete);
        }


        private function onListingComplete(op:LFS_ListingCLO):void {
            if (status.isCanceled) {
                return;
            }

            _nodesQueue = _nodesQueue.concat(op.nodes);
            listingIndex += 1;

            if (listingIndex == sourceNodes.length || sourceNodes.length == 0) {
                // Finish
                _processingNodeIndex = 0;
                moveNextFile();
            }
            else {
                getNextListing();
            }
        }


        /**
         * Add Extra options to interaction message before it will be
         * caught by another code
         */
        private function onInteractionMessage(i:Interaction):void {
            var msg:InteractionMessage = i.getMessage() as InteractionMessage;
            msg.options.push(new InteractionOption("n", "Skip All", SKIP_ALL));
            msg.options.push(new InteractionOption("y", "Overwrite All", OVERWRITE_ALL));
            msg.onResponse(onInteractionResponse);
        }


        /**
         * Check extra options and modify startup params
         * @param option
         */
        private function onInteractionResponse(option:InteractionOption):void {
            if (notEmpty(option.context)) {
                parameters.param(option.context).value = true;
            }
        }


        override public function cancel():void {
            if (cmdLineOperation) {
                cmdLineOperation.cancel();
            }
            if (listingOp) {
                listingOp.cancel();
            }
            super.cancel();
        }


        // -----------------------------------------------------------------------------------
        // Move CMD
        // -----------------------------------------------------------------------------------

        private var cmdLineOperation:IAsyncOperation;
        private var dirsToRemoveQueue:Array = [];
        private var dirToRemoveIndex:Number;


        private function moveNextFile():void {
            if (cmdLineOperation || status.isCanceled) {
                return;
            }

            if (_processingNodeIndex == nodesQueue.length) {
                dirToRemoveIndex = 0;
                removeNextEmptyDir();
            }
            else {
                var refNode:ReferenceNode = nodesQueue[_processingNodeIndex];

                if (refNode.fileType == FileType.DIRECTORY) {
                    dirsToRemoveQueue.push(refNode);

                    cmdLineOperation = new LFS_MakeDirCLO()
                        .path(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .execute();

                    cmdLineOperation
                        .status
                        .onFinish(continueMove);
                }
                else {
                    cmdLineOperation = new LFS_MoveCLO()
                        .sourceFilePath(refNode.reference)
                        .targetFilePath(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .overwriteExisting(parameters.param(OVERWRITE_ALL).value)
                        .skipExisting(parameters.param(SKIP_ALL).value)
                        .execute();

                    cmdLineOperation
                        .status
                        .onComplete(continueMove)
                        .onFault(onCmdLineOperationFault);

                    // Traverse remote interaction to ours
                    interaction.listenTo(IInteractiveOperation(cmdLineOperation).getInteraction());
                }
            }
        }


        private function removeNextEmptyDir():void {
            var refNode:ReferenceNode = dirsToRemoveQueue[dirsToRemoveQueue.length - dirToRemoveIndex - 1];

            cmdLineOperation = new LFS_RemoveDirCLO()
                .setPath(refNode.reference)
                .execute();

            cmdLineOperation
                .status
                .onFinish(onRemoveDirectoryComplete);
        }


        private function onRemoveDirectoryComplete(op:IAsyncOperation):void {
            if (dirToRemoveIndex == dirsToRemoveQueue.length - 1) {
                done();
            }
            else {
                // last 10% of progress is used for delete dirs
                _progress.setPercent(90 + processingNodeIndex / nodesQueue.length * 10, this);
                dirToRemoveIndex += 1;
                removeNextEmptyDir();
            }
        }


        private function onCmdLineOperationFault(op:IAsyncOperation):void {
            fault();
        }


        private function continueMove(op:IAsyncOperation):void {
            _progress.setPercent(processingNodeIndex / nodesQueue.length * 90, this);
            _processingNodeIndex += 1;
            cmdLineOperation = null;
            moveNextFile();
        }

    }
}
