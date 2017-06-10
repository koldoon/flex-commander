package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.interactive.impl.Message;
    import ru.koldoon.fc.m.parametrized.IParameters;
    import ru.koldoon.fc.m.parametrized.IParametrized;
    import ru.koldoon.fc.m.parametrized.impl.Param;
    import ru.koldoon.fc.m.parametrized.impl.Parameters;
    import ru.koldoon.fc.m.progress.IProgressReporter;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_RemoveCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_TrashCLO;

    public class LFS_RemoveOperation extends AbstractNodesBunchOperation
        implements IParametrized, ITreeRemoveOperation, IProgressReporter, IInteractive {

        public static const MOVE_TO_TRASH:String = "MOVE_TO_TRASH";


        public function LFS_RemoveOperation() {
            parameters.setup([
                new Param(MOVE_TO_TRASH, true)
            ]);
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
        public function setNodes(value:Array):ITreeRemoveOperation {
            _sourceNodes = value;
            return this;
        }


        override protected function begin():void {
            _nodesQueue = [];
            _processingNodeIndex = 0;

            // collect file system references
            for each (var n:INode in _sourceNodes) {
                _nodesQueue.push(new ReferenceNode(n.name, null, FileNodeUtil.getPath(n)));
            }
            removeNextFile();
        }


        // -----------------------------------------------------------------------------------
        // Remove CMD
        // -----------------------------------------------------------------------------------

        private var cmdLineOperation:IAsyncOperation;


        private function removeNextFile():void {
            if (cmdLineOperation || status.isCanceled) {
                return;
            }

            if (!nodesQueue || _processingNodeIndex == nodesQueue.length) {
                done();
            }
            else {
                var fsRef:ReferenceNode = _nodesQueue[_processingNodeIndex];

                if (parameters.param(MOVE_TO_TRASH).value) {
                    cmdLineOperation = new LFS_TrashCLO()
                        .setPath(fsRef.reference);
                }
                else {
                    cmdLineOperation = new LFS_RemoveCLO()
                        .setPath(fsRef.reference);
                }

                if (cmdLineOperation is IInteractive) {
                    _interaction.listenTo(IInteractive(cmdLineOperation).interaction);
                }

                cmdLineOperation
                    .status
                    .onComplete(continueRemove)
                    .onError(onCmdLineOperationFault)
                    .operation
                    .execute();
            }
        }


        private function onCmdLineOperationFault(op:IAsyncOperation):void {
            if (!(cmdLineOperation is IInteractive)) {
                _interaction.setMessage(new Message().setText("CmdLineOperation Error"));
            }
            fault();
        }


        private function continueRemove(op:IAsyncOperation):void {
            _progress.setPercent(processingNodeIndex / nodesQueue.length * 100, this);
            _processingNodeIndex += 1;
            cmdLineOperation = null;
            removeNextFile();
        }


        private var parameters:Parameters = new Parameters();
        private var _interaction:Interaction = new Interaction();
        private var _sourceNodes:Array;
    }
}
