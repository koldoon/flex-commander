package ru.koldoon.fc.m.tree.impl.fs {
    import flash.utils.Dictionary;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ILink;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.ITreeMkDirOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.ITreeRemoveOperation;
    import ru.koldoon.fc.m.tree.ITreeTransferOperation;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.DirectoryNode;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.LinkNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_ListingCLO;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_CopyOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_GetFilesOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_MakeDirOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_MoveOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_RemoveOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_ResolveLinkOperation;
    import ru.koldoon.fc.m.tree.impl.fs.op.LFS_ResolvePathOperation;

    public class LocalFileSystemTreeProvider extends DirectoryNode implements ITreeProvider, IFilesProvider, ITreeEditor {

        public function LocalFileSystemTreeProvider() {
            super("");
        }


        // -----------------------------------------------------------------------------------
        // ITreeProvider
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function getDirectoryListing(dir:IDirectory):IAsyncOperation {
            var self:* = this;
            var op:IAsyncOperation = new LFS_ListingCLO()
                .parentNode(dir)
                .path(FileNodeUtil.getAbsoluteFileSystemPath(dir))
                .includeHiddenFiles(false);

            op.status.onComplete(function (op:LFS_ListingCLO):void {
                DirectoryNode(dir).setNodes(op.getNodes());
                if (dir != self) {
                    DirectoryNode(dir).nodes.unshift(AbstractNode.PARENT_NODE);
                }
            });

            return pinAsyncOperation(op.execute());
        }


        public function resolveLink(lnk:ILink):IAsyncOperation {
            return pinAsyncOperation(new LFS_ResolveLinkOperation()
                .setLink(lnk as LinkNode));
        }


        public function getRootDirectory():IDirectory {
            return this;
        }


        public function resolvePathString(path:String):ITreeGetNodeOperation {
            return pinAsyncOperation(new LFS_ResolvePathOperation()
                .setPath(path)
                .setTreeProvider(this));
        }


        // -----------------------------------------------------------------------------------
        // IFilesProvider
        // -----------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function getFiles(nodes:Array, followLinks:Boolean = true):ICollectionPromise {
            var ac:CollectionPromise = new CollectionPromise();
            var op:IAsyncOperation = new LFS_GetFilesOperation()
                .setNodes(nodes)
                .followLinks(followLinks)
                .execute();

            op.status.onComplete(function (op:LFS_GetFilesOperation):void {
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
        public function move():ITreeTransferOperation {
            return pinAsyncOperation(new LFS_MoveOperation());
        }


        /**
         * @inheritDoc
         */
        public function copy():ITreeTransferOperation {
            return pinAsyncOperation(new LFS_CopyOperation());
        }


        /**
         * @inheritDoc
         */
        public function remove():ITreeRemoveOperation {
            return pinAsyncOperation(new LFS_RemoveOperation());
        }


        /**
         * @inheritDoc
         */
        public function mkDir():ITreeMkDirOperation {
            return pinAsyncOperation(new LFS_MakeDirOperation());
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
            op.status.onFinish(function (op:IAsyncOperation):void {
                delete operations[op];
            });

            return op;
        }
    }
}
