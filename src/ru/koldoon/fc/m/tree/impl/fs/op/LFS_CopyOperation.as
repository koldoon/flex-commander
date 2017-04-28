package ru.koldoon.fc.m.tree.impl.fs.op {
    import com.greensock.TweenMax;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Interaction;
    import ru.koldoon.fc.m.async.impl.InteractionMessage;
    import ru.koldoon.fc.m.async.impl.InteractionOption;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.impl.Parameters;
    import ru.koldoon.fc.m.async.impl.Progress;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.async.progress.IProgress;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodeProgressReporter;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.FileType;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_CopyCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_ListingCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;
    import ru.koldoon.fc.utils.isEmpty;
    import ru.koldoon.fc.utils.notEmpty;

    public class LFS_CopyOperation extends AbstractNodesBunchOperation
    implements IInteractiveOperation, IParametrized, ITreeTransferOperation, INodeProgressReporter {

        public static const OVERWRITE_EXISTING_FILES:String = "OVERWRITE_EXISTING_FILES";
        public static const SKIP_EXISTING_FILES:String = "SKIP_EXISTING_FILES";


        public function LFS_CopyOperation() {
            parameters.setup([
                new Param(OVERWRITE_EXISTING_FILES, false)
            ]);

            interaction.onMessage(onInteractionMessage);
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
        public function setSourceNodes(list:Array):ITreeTransferOperation {
            sourceNodes = list;
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


        /**
         * @inheritDoc
         */
        public function get processingNodeProgress():IProgress {
            return _processingNodeProgress;
        }

        override protected function begin():void {
            sourcePath = FileNodeUtil.getFileSystemPath(source);
            destinationPath = FileNodeUtil.getFileSystemPath(destination);

            _nodesQueue = [];
            listingIndex = 0;
            getNextListing();
        }


        override public function cancel():void {
            dispose();
            super.cancel();
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        private var source:IDirectory;
        private var destination:IDirectory;
        private var sourceNodes:Array;

        private var sourcePath:String;
        private var destinationPath:String;

        private var parameters:Parameters = new Parameters();
        private var interaction:Interaction = new Interaction();

        private var listingOp:IAsyncOperation;
        private var listingIndex:Number;

        private var _processingNodeProgress:Progress = new Progress();
        /**
         * Watch out for long copying processes.
         */
        private var cmdLineOperationObserver:TweenMax;




        private function getNextListing():void {
            var n:INode = sourceNodes[listingIndex];

            if (n is IDirectory) {
                // manually create and add root directory reference nodes, because they wont be
                // included in listings
                var referenceNode:ReferenceNode = new ReferenceNode(n.name, n.parent, FileNodeUtil.getFileSystemPath(n));
                referenceNode.fileType = FileType.DIRECTORY;
                referenceNode.attributes = FileNode(n).attributes;
                referenceNode.modified = FileNode(n).modified;
                _nodesQueue.push(referenceNode);
            }

            listingOp = new LFS_ListingCLO()
                .node(n)
                .followLinkNodes(false)
                .recursive(true)
                .createFlatReferences(true)
                .execute();

            listingOp
                .status
                .onFinish(onListingComplete);
        }


        private function onListingComplete(op:LFS_ListingCLO):void {
            if (status.isCanceled) {
                return;
            }

            _nodesQueue = _nodesQueue.concat(op.nodes);
            listingIndex += 1;

            if (listingIndex == sourceNodes.length || sourceNodes.length == 0) {
                cmdLineOperationObserver = TweenMax.to(this, 0.2, {
                    repeat:   -1,
                    onRepeat: updateNodeProgress
                });

                _processingNodeIndex = 0;
                copyNextFile();
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
            msg.options.push(new InteractionOption("n", "Skip All", SKIP_EXISTING_FILES));
            msg.options.push(new InteractionOption("y", "Overwrite All", OVERWRITE_EXISTING_FILES));
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


        // -----------------------------------------------------------------------------------
        // Copy CMD
        // -----------------------------------------------------------------------------------

        private var cmdLineOperation:IAsyncOperation;


        private function copyNextFile():void {
            if (cmdLineOperation || status.isCanceled) {
                return;
            }

            if (statusCmdLineOperation) {
                statusCmdLineOperation.cancel();
            }

            cmdLineOperationObserver.pause();

            if (!nodesQueue || processingNodeIndex == nodesQueue.length) {
                dispose();
                done();
            }
            else {
                var refNode:ReferenceNode = nodesQueue[processingNodeIndex];

                if (refNode.fileType == FileType.DIRECTORY) {
                    cmdLineOperation = new LFS_MakeDirCLO()
                        .path(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .execute();

                    cmdLineOperation
                        .status
                        .onComplete(continueCopy)
                        .onFault(onMkDirLineOperationFault);
                }
                else {
                    cmdLineOperation = new LFS_CopyCLO()
                        .sourceFilePath(refNode.reference)
                        .targetFilePath(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .overwriteExisting(parameters.param(OVERWRITE_EXISTING_FILES).value)
                        .skipExisting(parameters.param(SKIP_EXISTING_FILES).value)
                        .execute();

                    cmdLineOperation
                        .status
                        .onFault(onCopyCmdLineOperationFault)
                        .onFinish(continueCopy);

                    cmdLineOperationObserver.play(0);

                    // Traverse remote interaction to ours
                    interaction
                        .listenTo(IInteractiveOperation(cmdLineOperation).getInteraction())
                        .onMessage(cmdLineOperationObserver.pause);
                }
            }
        }


        private function onMkDirLineOperationFault(op:IAsyncOperation):void {
            status.info = op.status.info;
            dispose();
            fault();
        }


        private function onCopyCmdLineOperationFault(op:IAsyncOperation):void {

        }


        private var statusCmdLineOperation:IAsyncOperation;


        private function updateNodeProgress():void {
            var self:* = this;
            var srcNode:ReferenceNode = nodesQueue[processingNodeIndex];

            cmdLineOperationObserver.pause();

            statusCmdLineOperation = new LFS_ListingCLO()
                .path(FileNodeUtil.getTargetPath(sourcePath, srcNode.reference, destinationPath))
                .followLinkNodes(false)
                .recursive(false)
                .createFlatReferences(true)
                .execute();

            statusCmdLineOperation
                .status
                .onComplete(function (op:LFS_ListingCLO):void {
                    if (isEmpty(op.nodes)) {
                        return;
                    }
                    var dstNode:ReferenceNode = op.nodes[0] as ReferenceNode;
                    var nodeRatioTotalPercent:Number = 100 / nodesQueue.length;
                    var nodeRatioCurrent:Number = dstNode.size / srcNode.size;

                    _processingNodeProgress.setPercent(nodeRatioCurrent * 100, self);
                    _progress.setPercent(processingNodeIndex / nodesQueue.length * 100 + nodeRatioCurrent * nodeRatioTotalPercent, self);
                })
                .onFinish(function (data:Object):void {
                    cmdLineOperationObserver.play(0);
                });
        }


        private function continueCopy(op:IAsyncOperation):void {
            _processingNodeProgress.setPercent(100, this);
            _progress.setPercent((processingNodeIndex + 1) / nodesQueue.length * 100, this);
            _processingNodeIndex += 1;
            cmdLineOperation = null;
            statusCmdLineOperation = null;
            copyNextFile();
        }


        private function dispose():void {
            if (cmdLineOperation) {
                cmdLineOperation.cancel();
            }
            if (listingOp) {
                listingOp.cancel();
            }
            if (cmdLineOperationObserver) {
                cmdLineOperationObserver.kill();
            }
        }

    }
}
