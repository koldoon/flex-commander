package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;

    /**
     * Local File System file descriptor.
     * Includes full filesystem path and basic properties.
     */
    public class FileSystemReference {
        public function FileSystemReference(path:String, node:INode, size:int = 0) {
            _path = path;
            _node = node;
            _size = size;
        }


        /**
         * Parent node reference
         */
        public function get node():INode {
            return _node;
        }


        /**
         * Local File System Object path.
         * This may be a file or a directory
         */
        public function get path():String {
            return _path;
        }


        /**
         * File size in bytes if available
         */
        public function get size():int {
            return _size;
        }


        public function toString():String {
            return _path;
        }


        private var _path:String;
        private var _node:INode;
        private var _size:int;

    }
}
