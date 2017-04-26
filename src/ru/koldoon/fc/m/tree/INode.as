package ru.koldoon.fc.m.tree {
    /**
     * Common Tree node interface
     */
    public interface INode {

        /**
         * Parent Node
         */
        function get parent():INode;


        /**
         * Label Display and main node reference
         */
        function get name():String;


        /**
         * Associated Node Size in bytes.
         * Most operations with nodes rely on total amount of data
         * to process, that's why size is part of a common INode interface.
         */
        function get size():Number;


        /**
         * Text to display in the bottom of panel when this node is under the
         * selection caret
         */
        function getInfo():String;


        /**
         * Path string representation
         */
        function getPath():String;


        /**
         * Get nodes path from the very root to this node, including
         * all nested ITreeProvider-s and null-value nodes.
         * @see INode
         * @return Array of INode
         */
        function getNodesPath():Array;


        /**
         * Get superior ITreeProvider. The most methods for working
         * with nodes implemented there.
         * @see IFilesProvider
         * @see ITreeEditor
         * @see ITreeProvider
         * @return
         */
        function getTreeProvider():ITreeProvider;


        /**
         * Nodes can be parented by another nodes (as for ZIP files listing f.e.)
         * but in the very top there is a directory anyway because only IDirectory
         * can provide files listing;
         * @return
         */
        function getParentDirectory():IDirectory;
    }
}
