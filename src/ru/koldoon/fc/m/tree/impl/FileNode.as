package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.fs.FileNodeUtil;

    /**
     * Common implementation of Node representing File in different
     * FileSystem-s and Archives
     */
    public class FileNode extends AbstractNode {

        /**
         * Group 1: File Name
         * Group 2: File Extension
         */
        public static const FILE_TYPE_RXP:RegExp = /^([^\/*?|]+)\.([^\/*?|\s]{1,12})$/;


        public function FileNode(parent:INode, value:String, label:String = null) {
            super(parent, value, label);

            if (!(this is IDirectory)) {
                var t:Object = FILE_TYPE_RXP.exec(label || value);
                if (t) {
                    _type = t[2];
                }
            }
        }


        public var attributes:String;
        public var size:Number;
        public var modified:Date;
        public var executable:Boolean;
        public var link:Boolean;


        override public function get info():String {
            return link ? '-> ' + value : label;
        }


        public function getFormattedSize():String {
            return FileNodeUtil.getFormattedSize(size);
        }
    }
}
