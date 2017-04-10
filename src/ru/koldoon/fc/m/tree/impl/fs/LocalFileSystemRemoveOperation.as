package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.impl.Parameters;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNodesBunchOperation;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.fs.console.LocalFileSystemRemoveCommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.console.LocalFileSystemTrashCommandLineOperation;

    public class LocalFileSystemRemoveOperation extends AbstractNodesBunchOperation implements IParametrized, ITreeRemoveOperation {
        public static const MOVE_TO_TRASH:String = "MOVE_TO_TRASH";


        public function LocalFileSystemRemoveOperation() {
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
            _nodes = value;
            filesProvider = INode(nodesTotal[0]).getTreeProvider() as IFilesProvider;
            return this;
        }


        override protected function begin():void {
            filesProvider
                .getFiles(_nodes, false)
                .onReady(function (ac:ICollectionPromise):void {
                    filesReferences = ac.items;
                    _nodesProcessed = 0;
                    removeNextFile();
                });
        }


        // -----------------------------------------------------------------------------------
        // Copy CMD
        // -----------------------------------------------------------------------------------

        private var cmdLineOperation:IAsyncOperation;


        private function removeNextFile():void {
            if (cmdLineOperation || status.isCanceled) {
                return;
            }

            if (!nodesTotal || nodesProcessed == nodesTotal.length) {
                done();
            }
            else {
                var fsRef:FileSystemReference = filesReferences[nodesProcessed];

                if (parameters.param(MOVE_TO_TRASH).value) {
                    cmdLineOperation = new LocalFileSystemTrashCommandLineOperation()
                        .setPath(fsRef.path)
                        .execute();
                }
                else {
                    cmdLineOperation = new LocalFileSystemRemoveCommandLineOperation()
                        .setPath(fsRef.path)
                        .execute();
                }

                cmdLineOperation
                    .getStatus()
                    .onComplete(continueRemove)
                    .onFault(onCmdLineOperationFault);
            }
        }


        private function onCmdLineOperationFault(op:IAsyncOperation):void {
            fault();
        }


        private function continueRemove(op:IAsyncOperation):void {
            progress.setPercent(nodesProcessed / nodesTotal.length * 100, this);
            cmdLineOperation = null;
            _nodesProcessed += 1;
            removeNextFile();
        }


        private var parameters:Parameters = new Parameters();
        private var filesProvider:IFilesProvider;
        private var filesReferences:Array;
    }
}
