package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IInteractive;
    import ru.koldoon.fc.m.interactive.impl.Interaction;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.ITreeMkDirOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_MakeDirCLO;

    public class LFS_MakeDirOperation extends AbstractAsyncOperation implements ITreeMkDirOperation, IInteractive {

        public function setParent(d:IDirectory):ITreeMkDirOperation {
            parent = d;
            return this;
        }


        public function setName(n:String):ITreeMkDirOperation {
            name = n;
            return this;
        }


        override protected function begin():void {
            var path:String = FileNodeUtil.getPath(parent);

            cmdLineOperation = new LFS_MakeDirCLO()
                .path([path, name].join("/"))
                .status
                .onFinish(function (op:IAsyncOperation):void { done() })
                .onError(function (op:IAsyncOperation):void { fault() })
                .operation;

            _interaction
                .listenTo(IInteractive(cmdLineOperation).interaction);

            cmdLineOperation
                .execute();
        }


        /**
         * @inheritDoc
         */
        public function get interaction():IInteraction {
            return _interaction;
        }


        private var name:String;
        private var parent:IDirectory;
        private var cmdLineOperation:IAsyncOperation;
        private var _interaction:Interaction = new Interaction();
    }
}
