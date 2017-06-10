package ru.koldoon.fc.m.tree.impl.fs.op {
    import com.greensock.TweenMax;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.interactive.impl.InteractionOption;
    import ru.koldoon.fc.m.interactive.impl.SelectOptionMessage;
    import ru.koldoon.fc.m.parametrized.IParameters;
    import ru.koldoon.fc.m.parametrized.IParametrized;
    import ru.koldoon.fc.m.parametrized.impl.Param;
    import ru.koldoon.fc.m.parametrized.impl.Parameters;
    import ru.koldoon.fc.m.progress.IProgress;
    import ru.koldoon.fc.m.progress.impl.Progress;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.INodeProgressReporter;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileNode;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.FileType;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_ListingCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MoveCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_RemoveDirCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_StatCLO;
    import ru.koldoon.fc.utils.isEmpty;
    import ru.koldoon.fc.utils.notEmpty;

    public class LFS_MoveOperation extends AbstractNodesBunchOperation
        implements IInteractive, IParametrized, ITreeTransferOperation, INodeProgressReporter {

        public static const OVERWRITE_ALL:String = "OVERWRITE_ALL";
        public static const SKIP_ALL:String = "SKIP_ALL";


        public function LFS_MoveOperation() {
            parameters.setup([
                new Param(SKIP_ALL, false)
            ]);

            _interaction.onMessage(onInteractionMessage);
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
        public function get interaction():IInteraction {
            return _interaction;
        }


        /**
         * @inheritDoc
         */
        public function get processingNodeProgress():IProgress {
            return _processingNodeProgress;
        }


        override protected function begin():void {
            sourcePath = FileNodeUtil.getPath(source);
            destinationPath = FileNodeUtil.getPath(destination);

            _nodesQueue = [];
            listingIndex = 0;
            getNextListing()
        }


        override public function cancel():void {
            dispose();
            super.cancel();
        }


        private var source:IDirectory;
        private var destination:IDirectory;
        private var sourceNodes:Array;

        private var sourcePath:String;
        private var destinationPath:String;

        private var parameters:Parameters = new Parameters();
        private var _interaction:Interaction = new Interaction();

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
                // Add source directories to remove queue
                dirsToRemoveQueue.push(new ReferenceNode(n.name, null, FileNodeUtil.getPath(n)));

                // manually create and add root directory reference nodes, because they wont be
                // included in listings
                var referenceNode:ReferenceNode = new ReferenceNode(n.name, n.parent, FileNodeUtil.getPath(n));
                referenceNode.fileType = FileType.DIRECTORY;
                referenceNode.attributes = FileNode(n).attributes;
                referenceNode.modified = FileNode(n).modified;
                _nodesQueue.push(referenceNode);
            }

            listingOp = new LFS_ListingCLO()
                .parentNode(n)
                .path(FileNodeUtil.getPath(n))
                .followLinkNodes(false)
                .recursive(true)
                .createReferenceNodes(true)
                .status
                .onFinish(onListingComplete)
                .operation
                .execute();
        }


        private function onListingComplete(op:LFS_ListingCLO):void {
            if (status.isCanceled) {
                return;
            }

            _nodesQueue = _nodesQueue.concat(op.getNodes());
            listingIndex += 1;

            if (listingIndex == sourceNodes.length || sourceNodes.length == 0) {
                cmdLineOperationObserver = TweenMax.to(this, 0.2, {
                    repeat:   -1,
                    onRepeat: updateNodeProgress
                });

                if (nodesQueue.length > 0) {
                    _processingNodeIndex = 0;
                    moveNextFile();
                }
                else {
                    done();
                }
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
            var msg:SelectOptionMessage = i.getMessage() as SelectOptionMessage;
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


        // -----------------------------------------------------------------------------------
        // Move CMD
        // -----------------------------------------------------------------------------------

        private var removeCmdLineOperation:IAsyncOperation;
        private var dirsToRemoveQueue:Array = [];
        private var dirToRemoveIndex:Number;


        private function moveNextFile():void {
            if (removeCmdLineOperation || status.isCanceled) {
                return;
            }

            if (statCmdLineOperation) {
                statCmdLineOperation.cancel();
            }

            cmdLineOperationObserver.pause();

            if (_processingNodeIndex == nodesQueue.length) {
                cmdLineOperationObserver.pause();

                if (dirsToRemoveQueue.length == 0) {
                    dispose();
                    done();
                }
                else {
                    dirToRemoveIndex = 0;
                    _processingNodeIndex = nodesQueue.length - 1; // to prevent NPE
                    removeNextEmptyDir();
                }
            }
            else {
                var refNode:ReferenceNode = nodesQueue[_processingNodeIndex];

                if (refNode.fileType == FileType.DIRECTORY) {
                    dirsToRemoveQueue.push(refNode);

                    removeCmdLineOperation = new LFS_MakeDirCLO()
                        .path(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .status
                        .onComplete(continueMove)
                        .onError(onMkDirCmdLineOperationFault)
                        .operation;
                }
                else {
                    removeCmdLineOperation = new LFS_MoveCLO()
                        .sourceFilePath(refNode.reference)
                        .targetFilePath(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .overwriteExisting(parameters.param(OVERWRITE_ALL).value)
                        .skipExisting(parameters.param(SKIP_ALL).value)
                        .status
                        .onFinish(continueMove)
                        .onError(onCmdLineOperationFault)
                        .operation;
                }

                // Traverse remote interaction to ours
                _interaction
                    .listenTo(IInteractive(removeCmdLineOperation).interaction)
                    .onMessage(cmdLineOperationObserver.pause);

                removeCmdLineOperation
                    .execute();

                cmdLineOperationObserver.play(0);
            }
        }


        private function onMkDirCmdLineOperationFault(op:IAsyncOperation):void {
            dispose();
            fault();
        }


        private function removeNextEmptyDir():void {
            var refNode:ReferenceNode = dirsToRemoveQueue[dirsToRemoveQueue.length - dirToRemoveIndex - 1];

            removeCmdLineOperation = new LFS_RemoveDirCLO()
                .setPath(refNode.reference)
                .status
                .onFinish(onRemoveDirectoryComplete)
                .operation
                .execute();
        }


        private function onRemoveDirectoryComplete(op:IAsyncOperation):void {
            if (dirToRemoveIndex == dirsToRemoveQueue.length - 1) {
                dispose();
                done();
            }
            else {
                // last 10% of progress is used to show delete dirs processing
                _progress.setPercent(90 + (dirToRemoveIndex / dirsToRemoveQueue.length * 10), this);
                dirToRemoveIndex += 1;
                removeNextEmptyDir();
            }
        }


        private var statCmdLineOperation:IAsyncOperation;


        private function updateNodeProgress():void {
            if (!nodesQueue || nodesQueue.length <= processingNodeIndex) {
                return;
            }

            var self:* = this;
            var srcNode:ReferenceNode = nodesQueue[processingNodeIndex];
            var srcRef:String = srcNode ? srcNode.reference : null;

            if (isEmpty(srcRef)) {
                return;
            }

            cmdLineOperationObserver.pause();

            statCmdLineOperation = new LFS_StatCLO()
                .path(FileNodeUtil.getTargetPath(sourcePath, srcRef, destinationPath))
                .createReferenceNode(true)
                .status
                .onComplete(function (op:LFS_StatCLO):void {
                    var dstNode:INode = op.getNode();
                    if (!dstNode) {
                        return;
                    }

                    var nodeRatioTotalPercent:Number = 100 / nodesQueue.length;
                    var nodeRatioCurrent:Number = dstNode.size / srcNode.size;

                    _processingNodeProgress.setPercent(nodeRatioCurrent * 100, self);
                    _progress.setPercent(processingNodeIndex / nodesQueue.length * 100 + nodeRatioCurrent * nodeRatioTotalPercent, self);
                })
                .onFinish(function (data:Object):void {
                    if (status.isProcessing) {
                        cmdLineOperationObserver.play(0);
                    }
                })
                .operation
                .execute();
        }


        private function onCmdLineOperationFault(op:IAsyncOperation):void {
            fault();
        }


        private function continueMove(op:IAsyncOperation):void {
            _processingNodeProgress.setPercent(100, this);
            _progress.setPercent((processingNodeIndex + 1) / nodesQueue.length * 90, this);
            _processingNodeIndex += 1;
            removeCmdLineOperation = null;
            statCmdLineOperation = null;
            moveNextFile();
        }


        private function dispose():void {
            if (removeCmdLineOperation) {
                removeCmdLineOperation.cancel();
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
