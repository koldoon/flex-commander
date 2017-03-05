package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;

    /**
     * Abstract Realization of INode interface.
     */
    public class AbstractNode implements INode {
        public static const PARENT_NODE:AbstractNode = new AbstractNode(null, "..");


        public function AbstractNode(parent:INode, value:String, label:String = null) {
            _parent = parent;
            _value = value;
            _label = label;
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
        [Bindable(event="__noChangeEvent__")]
        public function get value():String {
            return _value;
        }


        /**
         * @inheritDoc
         */
        public function get type():String {
            return _type;
        }


        /**
         * @inheritDoc
         */
        public function get label():String {
            return _label || _value;
        }


        /**
         * @inheritDoc
         */
        public function get info():String {
            return _value;
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
            return label;
        }


        protected var _type:String;
        protected var _parent:INode;
        protected var _value:String;
        protected var _label:String;
    }
}
