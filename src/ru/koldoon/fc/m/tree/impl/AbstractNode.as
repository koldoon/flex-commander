package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;

    /**
     * Abstract Realization of INode interface.
     */
    public class AbstractNode implements INode {
        public static const PARENT_NODE:AbstractNode = new AbstractNode(null, "..");


        public function AbstractNode(parent:INode, name:String = null, link:String = null) {
            _parent = parent;
            _link = link;
            _name = name;
        }


        /**
         * @inheritDoc
         */
        public function get parent():INode {
            return _parent;
        }


        /**
         * @inheritDoc
         */
        public function get link():String {
            return _link;
        }


        /**
         * @inheritDoc
         */
        public function get name():String {
            return _name;
        }


        /**
         * @inheritDoc
         */
        public function get info():String {
            // default implementation
            return _link;
        }


        /**
         * @inheritDoc
         */
        public function getPath():Array {
            var n:INode = this;
            var path:Array = [n];
            while (n.parent) {
                n = n.parent;
                path.unshift(n);
            }
            return path;
        }


        /**
         * @inheritDoc
         */
        public function getTreeProvider():ITreeProvider {
            var p:INode = parent;
            while (p.parent && !(p is ITreeProvider)) {
                p = p.parent;
            }
            return p as ITreeProvider;
        }


        /**
         * @inheritDoc
         */
        public function getParentDirectory():IDirectory {
            var n:INode = parent;
            while (n && n.parent && !(n is IDirectory)) {
                n = n.parent;
            }
            return n as IDirectory;
        }


        public function toString():String {
            return name || link;
        }


        protected var _parent:INode;
        protected var _link:String;
        protected var _name:String;
    }
}
