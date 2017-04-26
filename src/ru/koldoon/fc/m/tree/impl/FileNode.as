package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;

    /**
     * Common implementation of Node representing File in different
     * FileSystem-s
     */
    public class FileNode extends AbstractNode {

        /**
         * Group 1: File Name
         * Group 2: File Extension
         */
        public static const FILE_EXTENSION_RXP:RegExp = /^([^\/*?|]+)\.([^\/*?|\s]{1,12})$/;


        public function FileNode(name:String, parent:INode) {
            super(name, parent);

            if (!(this is IDirectory)) {
                var t:Object = FILE_EXTENSION_RXP.exec(name);
                if (t) {
                    extension = t[2];
                }
            }
        }


        /**
         * File attributes in "ls" style
         */
        public var attributes:String;

        /**
         * Modified date
         */
        public var modified:Date;

        /**
         * Executable flag
         */
        public var executable:Boolean;

        /**
         * Typical file extension: file name part after the last "dot"
         */
        public var extension:String;

        /**
         * Node type. Standard types are described by FileType class
         */
        public var fileType:int;


        public function getFormattedSize():String {
            return FileNodeUtil.getFormattedSize(size);
        }
    }
}
