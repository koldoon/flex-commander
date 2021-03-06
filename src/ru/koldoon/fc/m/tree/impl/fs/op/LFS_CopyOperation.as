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
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_CopyCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_ListingCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_StatCLO;
    import ru.koldoon.fc.utils.isEmpty;
    import ru.koldoon.fc.utils.notEmpty;

    public class LFS_CopyOperation extends AbstractNodesBunchOperation
        implements IInteractive, IParametrized, ITreeTransferOperation, INodeProgressReporter {

        public static const OVERWRITE_EXISTING_FILES:String = "OVERWRITE_EXISTING_FILES";
        public static const SKIP_EXISTING_FILES:String = "SKIP_EXISTING_FILES";


        public function LFS_CopyOperation() {
            parameters.setup([
                new Param(OVERWRITE_EXISTING_FILES, false)
            ]);

            _interaction.onMessage(onInteractionMessage);
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
        private var listingOp:IAsyncOperation;
        private var listingIndex:Number;

        private var _interaction:Interaction = new Interaction();
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

                _processingNodeIndex = 0;
                copyNextFile();
            }
            else {
                getNextListing();
            }
        }


        /**
         * Add Extra options to overwrite interaction message options before it will be
         * caught by another code
         */
        private function onInteractionMessage(i:Interaction):void {
            var msg:SelectOptionMessage = i.getMessage() as SelectOptionMessage;

            if (msg) {
                msg.options.push(new InteractionOption("n", "Skip All", SKIP_EXISTING_FILES));
                msg.options.push(new InteractionOption("y", "Overwrite All", OVERWRITE_EXISTING_FILES));
                msg.onResponse(onInteractionResponse);
            }
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

        private var copyCmdLineOperation:IAsyncOperation;
        private var failedDir:String;


        private function copyNextFile():void {
            if (copyCmdLineOperation || status.isCanceled) {
                return;
            }

            if (statCmdLineOperation) {
                statCmdLineOperation.cancel();
            }

            cmdLineOperationObserver.pause();

            if (!nodesQueue || processingNodeIndex >= nodesQueue.length) {
                dispose();
                done();
            }
            else {
                var refNode:ReferenceNode = nodesQueue[processingNodeIndex];
                if (failedDir && refNode.reference.indexOf(failedDir) != -1) {
                    continueCopy();
                }

                if (refNode.fileType == FileType.DIRECTORY) {
                    copyCmdLineOperation = new LFS_MakeDirCLO()
                        .path(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .status
                        .onComplete(onMkDirOperationComplete)
                        .onError(onMkDirLineOperationFault)
                        .operation;
                }
                else {
                    copyCmdLineOperation = new LFS_CopyCLO()
                        .sourceFilePath(refNode.reference)
                        .targetFilePath(FileNodeUtil.getTargetPath(sourcePath, refNode.reference, destinationPath))
                        .overwriteExisting(parameters.param(OVERWRITE_EXISTING_FILES).value)
                        .skipExisting(parameters.param(SKIP_EXISTING_FILES).value)
                        .status
                        .onError(onCopyCmdLineOperationFault)
                        .onFinish(continueCopy)
                        .operation;

                    cmdLineOperationObserver.play(0);
                }

                // Traverse remote interaction to ours
                _interaction
                    .listenTo(IInteractive(copyCmdLineOperation).interaction)
                    .onMessage(cmdLineOperationObserver.pause);

                copyCmdLineOperation
                    .execute();
            }
        }


        private function onMkDirOperationComplete(op:LFS_MakeDirCLO):void {
            failedDir = null;
            continueCopy();
        }


        private function onMkDirLineOperationFault(op:LFS_MakeDirCLO):void {
            failedDir = op.getPath();
            continueCopy();
        }


        private function onCopyCmdLineOperationFault(op:IAsyncOperation):void {
            continueCopy();
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


        private function continueCopy(op:IAsyncOperation = null):void {
            _processingNodeProgress.setPercent(100, this);
            _progress.setPercent((processingNodeIndex + 1) / nodesQueue.length * 100, this);
            _processingNodeIndex += 1;
            copyCmdLineOperation = null;
            statCmdLineOperation = null;
            copyNextFile();
        }


        private function dispose():void {
            if (copyCmdLineOperation) {
                copyCmdLineOperation.cancel();
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
