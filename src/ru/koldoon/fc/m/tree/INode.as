package ru.koldoon.fc.m.tree {
    public interface INode {

        /**
         * Parent Node
         */
        function get parent():INode;


        /**
         * Link info, if this node is a link.
         * Usually an absolute or relative path.
         */
        function get link():String;


        /**
         * Label Display and main node reference
         */
        function get name():String;


        /**
         * Text to display in the bottom of panel when this node is under the
         * selection caret
         */
        function get info():String;


        /**
         * Get nodesTotal path from the very root to this node, including
         * all nested ITreeProvider-s and null-value nodesTotal.
         * @see INode
         * @return Array of INode
         */
        function getPath():Array;


        /**
         * Get superior ITreeProvider. The most methods for working
         * with nodesTotal implemented there.
         * @see IFilesProvider
         * @see ITreeEditor
         * @see ITreeProvider
         * @return
         */
        function getTreeProvider():ITreeProvider;


        /**
         * Nodes can be parented by another nodesTotal (as for ZIP files listing f.e.)
         * but in the very top there is a directory anyway because only IDirectory
         * can provide files listing;
         * @return
         */
        function getParentDirectory():IDirectory;
    }
}
