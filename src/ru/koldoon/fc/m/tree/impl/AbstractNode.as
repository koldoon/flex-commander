package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;

    /**
     * Abstract Realization of INode interface.
     */
    public class AbstractNode implements INode {
        public static const PARENT_NODE:AbstractNode = new AbstractNode("..");


        public function AbstractNode(name:String = null, parent:INode = null) {
            _parent = parent;
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
        public function get name():String {
            return _name;
        }


        /**
         * Size in bytes. There is also setter for size, because it can be set
         * later, for Directories for example
         */
        public function get size():Number {
            return _size;
        }


        public function set size(v:Number):void {
            _size = v;
        }


        /**
         * @inheritDoc
         */
        public function getInfo():String {
            return _name;
        }


        /**
         * @inheritDoc
         */
        public function getNodesPath():Array {
            var n:INode = this;
            var path:Array = [n];
            while (n.parent) {
                n = n.parent;
                path.unshift(n);
            }
            return path;
        }


        public function getPath():String {
            return getNodesPath().join("/");
        }


        /**
         * @inheritDoc
         */
        public function getTreeProvider():ITreeProvider {
            var p:INode = this;
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
            return name;
        }


        protected var _parent:INode;
        protected var _name:String;
        protected var _size:Number;
    }
}
