package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;

    /**
     * Node in flat list structure, where slash separated "reference" string
     * is the only information about tree hierarchy.
     */
    public class ReferenceNode extends FileNode {

        public function ReferenceNode(name:String, parent:INode, ref:String) {
            super(name, parent);
            this.reference = ref;
        }


        /**
         * File system or another path reference.
         * This is simplified path from to some statically defined node.
         */
        public var reference:String;


        override public function toString():String {
            return reference;
        }
    }
}
