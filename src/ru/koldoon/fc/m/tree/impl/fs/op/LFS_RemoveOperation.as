package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.impl.Parameters;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.ReferenceNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_RemoveCLO;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_TrashCLO;

    public class LFS_RemoveOperation extends AbstractNodesBunchOperation
        implements IParametrized, ITreeRemoveOperation, IProgressReporter {

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
                        .setPath(fsRef.reference)
                        .execute();
                }
                else {
                    cmdLineOperation = new LFS_RemoveCLO()
                        .setPath(fsRef.reference)
                        .execute();
                }

                cmdLineOperation
                    .status
                    .onComplete(continueRemove)
                    .onFault(onCmdLineOperationFault);
            }
        }


        private function onCmdLineOperationFault(op:IAsyncOperation):void {
            status.info = op.status.info;
            fault();
        }


        private function continueRemove(op:IAsyncOperation):void {
            _progress.setPercent(processingNodeIndex / nodesQueue.length * 100, this);
            _processingNodeIndex += 1;
            cmdLineOperation = null;
            removeNextFile();
        }


        private var parameters:Parameters = new Parameters();
        private var _sourceNodes:Array;
    }
}
