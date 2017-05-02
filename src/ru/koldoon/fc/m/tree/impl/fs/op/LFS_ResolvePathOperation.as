package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_StatCLO;

    public class LFS_ResolvePathOperation extends AbstractAsyncOperation implements ITreeGetNodeOperation {

        /**
         * @inheritDoc
         */
        public function getNode():INode {
            return _node;
        }


        /**
         * Path string to resolve
         */
        public function setPath(value:String):LFS_ResolvePathOperation {
            _path = value;
            _currentPath = value.split(":").shift();
            return this;
        }


        /**
         * TreeProvider instance to use as a root source
         */
        public function setTreeProvider(tp:ITreeProvider):LFS_ResolvePathOperation {
            _treeProvider = tp;
            return this;
        }


        override protected function begin():void {
            currentPathIndex = 1; // skipping empty root
            _node = _treeProvider.getRootDirectory();
            getNextNode();
        }


        private function getNextNode():void {
            statOperation = new LFS_StatCLO()
                .parentNode(_node)
                .path(_currentPath.split("/").slice(0, currentPathIndex + 1).join("/"))
                .execute();

            statOperation
                .status
                .onComplete(function (op:LFS_StatCLO):void {
                    _node = op.getNode();
                    if (currentPathIndex == _currentPath.split("/").length - 1) {
                        done();
                    }
                    else {
                        currentPathIndex += 1;
                        getNextNode();
                    }
                })
                .onFault(function (op:LFS_StatCLO):void {
                    fault();
                });
        }


        private var _path:String;
        /**
         * Path in current tree provider;
         */
        private var _currentPath:String;
        private var _node:INode;
        private var _treeProvider:ITreeProvider;

        private var currentPathIndex:int;
        private var statOperation:IAsyncOperation;
    }
}
