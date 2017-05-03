package ru.koldoon.fc.m.tree.impl.fs.op {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeGetNodeOperation;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;
    import ru.koldoon.fc.m.tree.impl.LinkNode;
    import ru.koldoon.fc.m.tree.impl.fs.cl.LFS_StatCLO;

    public class LFS_ResolveLinkOperation extends AbstractAsyncOperation implements ITreeGetNodeOperation {
        /**
         * Source link node
         */
        public function setLink(value:LinkNode):LFS_ResolveLinkOperation {
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
            if (!_link) {
                throw new Error("Link is not defined or a wrong type (Not a LinkNode)");
            }

            resolveCurrentLink();
        }


        private function resolveCurrentLink():void {
            var linkPath:String = FileNodeUtil.getAbsoluteFileSystemPath(_link);
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
                        _link.setTarget(_node);
                        _link = _node as LinkNode;

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


        private var _link:LinkNode;
        private var _node:INode;
        private var statOperation:IAsyncOperation;

        /**
         * Store links visited to prevent cycles
         */
        private var linksIndex:Object = {};
    }
}
