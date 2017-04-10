package ru.koldoon.fc.m.tree.impl.fs {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeMkDirOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.ITreeTransmitOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.fs.console.LocalFileSystemDirectoryListingCommandLineOperation;

    public class LocalFileSystemTreeProvider extends AbstractNode implements ITreeProvider, IFilesProvider, ITreeEditor {

        public function LocalFileSystemTreeProvider() {
            super(null, "");
        }


        // -----------------------------------------------------------------------------------
        // ITreeProvider
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function getListingFor(dir:IDirectory):ICollectionPromise {
            var ac:CollectionPromise = new CollectionPromise();
            var op:IAsyncOperation = new LocalFileSystemDirectoryListingCommandLineOperation()
                .setDirectory(dir)
                .execute();

            op.getStatus().onComplete(function (op:LocalFileSystemDirectoryListingCommandLineOperation):void {
                ac.applyResult(op.nodes);
            });

            ac.onReject(function ():void {
                op.cancel();
            });

            pinAsyncOperation(op);
            return ac;
        }


        public function getRootDirectory():IDirectory {
            return new DirectoryNode(this, "");
        }


        // -----------------------------------------------------------------------------------
        // IFilesProvider
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function getFiles(nodes:Array, followLinks:Boolean = true):ICollectionPromise {
            var ac:CollectionPromise = new CollectionPromise();
            var op:IAsyncOperation = new LocalFileSystemGetFilesOperation()
                .setNodes(nodes)
                .followLinks(followLinks)
                .execute();

            op.getStatus().onComplete(function (op:LocalFileSystemGetFilesOperation):void {
                ac.applyResult(op.files);
            });

            pinAsyncOperation(op);
            return ac;
        }


        /**
         * @inheritDoc
         */
        public function putFiles(files:FileSystemReference, toDir:IDirectory):IAsyncOperation {
            return null;
        }


        /**
         * @inheritDoc
         */
        public function purge():IAsyncOperation {
            return null;
        }


        // -----------------------------------------------------------------------------------
        // ITreeEditor
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function move():ITreeTransmitOperation {
            return null;
        }


        /**
         * @inheritDoc
         */
        public function copy():ITreeTransmitOperation {
            return pinAsyncOperation(new LocalFileSystemCopyOperation());
        }


        /**
         * @inheritDoc
         */
        public function remove():ITreeRemoveOperation {
            return pinAsyncOperation(new LocalFileSystemRemoveOperation());
        }


        /**
         * @inheritDoc
         */
        public function mkDir():ITreeMkDirOperation {
            return pinAsyncOperation(new LocalFileSystemMkDirOperation());
        }


        /**
         * Pinned operations references are stored here
         */
        private var operations:Dictionary = new Dictionary();


        /**
         * Prevent executable operations being garbage collected
         * before finish.
         */
        private function pinAsyncOperation(op:IAsyncOperation):* {
            operations[op] = true;
            op.getStatus().onFinish(function (op:IAsyncOperation):void {
                delete operations[op];
            });

            return op;
        }
    }
}
