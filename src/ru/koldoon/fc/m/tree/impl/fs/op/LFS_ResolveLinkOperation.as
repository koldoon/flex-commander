package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.ILink;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_StatCLO;

    public class LFS_ResolveLinkOperation extends AbstractAsyncOperation implements ITreeGetNodeOperation {
        /**
         * Source link node
         */
        public function setLink(value:ILink):LFS_ResolveLinkOperation {
            _link = value;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function getNode():INode {
            return _node;
        }


        override protected function begin():void {
            resolveCurrentLink();
        }


        private function resolveCurrentLink():void {
            var linkPath:String = FileNodeUtil.getFileSystemPath(_link, "all");
            if (linksIndex[linkPath]) {
                // seems as if we've found a cycled link
                fault();
            }
            else {
                linksIndex[linkPath] = true;

                statOperation = new LFS_StatCLO()
                    .parentNode(_link)
                    .path(linkPath)
                    .execute();

                statOperation
                    .status
                    .onComplete(function (op:LFS_StatCLO):void {
                        _node = op.getNode();
                        _link = _node as ILink;

                        if (_link) {
                            resolveCurrentLink();
                        }
                        else {
                            done();
                        }
                    })
                    .onFault(function (op:LFS_StatCLO):void {
                        fault();
                    });
            }
        }


        private var _link:ILink;
        private var _node:INode;
        private var statOperation:IAsyncOperation;

        /**
         * Store links visited to prevent cycles
         */
        private var linksIndex:Object = {};
    }
}
