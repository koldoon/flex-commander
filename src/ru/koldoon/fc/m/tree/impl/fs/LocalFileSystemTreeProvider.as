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
    import ru.koldoon.fc.m.tree.impl.fs.copy.LocalFileSystemCopyOperation;

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
                .execute();

            op.status
                .onComplete(function (op:LocalFileSystemDirectoryListingOperation):void {
                    ac.applyResult(op.nodes);
                    delete operations[op];
                });

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
                .execute();

            op.status
                .onComplete(function (op:LocalFileSystemGetFilesOperation):void {
                    ac.applyResult(op.files);
                    delete operations[op];
                });


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

        public function move(source:IDirectory, destination:IDirectory, nodes:Array = null):IAsyncOperation {
            return null;
        }


        public function copy(source:IDirectory, destination:IDirectory, nodes:Array = null):IAsyncOperation {
            return new LocalFileSystemCopyOperation()
                .source(source)
                .nodes(nodes)
                .destination(destination)
                .execute();
        }


        public function remove(nodes:Array):IAsyncOperation {
            return null;
        }
    }
}
