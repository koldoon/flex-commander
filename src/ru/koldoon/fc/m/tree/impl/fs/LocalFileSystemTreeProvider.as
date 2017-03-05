package ru.koldoon.fc.m.tree.impl.fs {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AsyncCollection;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;

    public class LocalFileSystemTreeProvider extends AbstractNode implements ITreeProvider, IFilesProvider, ITreeEditor {

        public function LocalFileSystemTreeProvider() {
            super(null, "");
        }


        /**
         * To prevent executable operations being garbage collected
         * before they finish.
         */
        private var operations:Dictionary = new Dictionary();


        // -----------------------------------------------------------------------------------
        // ITreeProvider
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function getListingFor(dir:IDirectory):IAsyncCollection {
            var ac:AsyncCollection = new AsyncCollection();
            var op:IAsyncOperation = new LocalFileSystemDirectoryListingOperation()
                .directory(dir)
                .onProgress(function (op:LocalFileSystemDirectoryListingOperation):void {
                    ac.items.source = op.files;
                })
                .onComplete(function (op:LocalFileSystemDirectoryListingOperation):void {
                    ac.applyResult(op.files);
                    delete operations[op];
                })
                .execute();

            ac.onReject(function ():void {
                op.cancel();
            });

            operations[op] = true;
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
        public function getFiles(nodes:Array):IAsyncCollection {
            var ac:AsyncCollection = new AsyncCollection();
            var op:IAsyncOperation = new LocalFileSystemGetFilesOperation()
                .nodes(nodes)
                .onComplete(function (op:LocalFileSystemGetFilesOperation):void {
                    ac.applyResult(op.files);
                    delete operations[op];
                })
                .execute();

            operations[op] = true;
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

        public function move(nodes:Array, toDir:IDirectory):IAsyncOperation {
            return null;
        }


        public function copy(nodes:Array, toDir:IDirectory):IAsyncOperation {
            return null;
        }


        public function remove(nodes:Array):IAsyncOperation {
            return null;
        }
    }
}
