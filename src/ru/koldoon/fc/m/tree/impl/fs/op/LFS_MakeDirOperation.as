package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ITreeMkDirOperation;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;

    public class LFS_MakeDirOperation extends AbstractAsyncOperation implements ITreeMkDirOperation {

        public function setParent(d:IDirectory):ITreeMkDirOperation {
            parent = d;
            return this;
        }


        public function setName(n:String):ITreeMkDirOperation {
            name = n;
            return this;
        }


        override protected function begin():void {
            IFilesProvider(parent.getTreeProvider())
                .getFiles([parent])
                .onReady(function (cp:ICollectionPromise):void {
                    var fsRef:FileSystemReference = cp.items[0];

                    cmdLineOperation = new LFS_MakeDirCLO()
                        .path([fsRef.path, name].join("/"))
                        .execute();

                    cmdLineOperation
                        .status
                        .onFinish(function (op:IAsyncOperation):void {
                            done();
                        })
                        .onFault(function (op:IAsyncOperation):void {
                            status.info = op.status.info;
                            fault();
                        });
                });
        }


        private var name:String;
        private var parent:IDirectory;
        private var cmdLineOperation:IAsyncOperation
    }
}