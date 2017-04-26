package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.ILink;
    import ru.koldoon.fc.m.tree.INode;

    public class LinkNode extends FileNode implements ILink {

        public function LinkNode(name:String, parent:INode, reference:String) {
            super(name, parent);
            this.reference = reference;
        }


        /**
         * Reference string, the actual target inside tree provider
         */
        public var reference:String;


        /**
         * @inheritDoc
         */
        public function get target():INode {
            return _target;
        }


        /**
         * @inheritDoc
         */
        public function resolve():IAsyncOperation {
            return getTreeProvider().resolveLink(this);
        }


        /**
         * @inheritDoc
         */
        override public function getInfo():String {
            return name + ' -> ' + reference;
        }


        private var _target:INode;
    }
}
