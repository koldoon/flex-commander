package ru.koldoon.fc.m.tree.impl.fs {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AsyncCollection;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeSelector;
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
            var asyncCollection:AsyncCollection = new AsyncCollection();
            var listingOp:LocalFileSystemDirectoryListingOperation = new LocalFileSystemDirectoryListingOperation();

            listingOp
                .directory(dir)
                .execute()
                .getStatus()
                .onComplete(function (op:LocalFileSystemDirectoryListingOperation):void {
                    asyncCollection.applyResult(op.nodes);
                    delete operations[op];
                });

            asyncCollection
                .onReject(function ():void {
                    listingOp.cancel();
                });

            operations[listingOp] = true;
            return asyncCollection;
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
        public function getFiles(nodes:Array, followLinks:Boolean = true):IAsyncCollection {
            var ac:AsyncCollection = new AsyncCollection();
            var op:IAsyncOperation = new LocalFileSystemGetFilesOperation()
                .nodes(nodes)
                .followLinks(followLinks)
                .execute();

            op.getStatus()
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

        /**
         * @inheritDoc
         */
        public function move(source:IDirectory, destination:IDirectory, selector:ITreeSelector):IAsyncOperation {
            return null;
        }


        /**
         * @inheritDoc
         */
        public function copy(source:IDirectory, destination:IDirectory, selector:ITreeSelector):IAsyncOperation {
            return new LocalFileSystemCopyOperation()
                .source(source)
                .treeSelector(selector)
                .destination(destination);
        }


        /**
         * @inheritDoc
         */
        public function remove(nodes:Array):IAsyncOperation {
            return null;
        }


        /**
         * @inheritDoc
         */
        public function createDirectory(name:String, parent:IDirectory):IAsyncOperation {
            return null;
        }
    }
}
