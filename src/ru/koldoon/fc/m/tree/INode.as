package ru.koldoon.fc.m.tree {
    public interface INode {

        /**
         * Parent Node
         */
        function get parent():INode;


        /**
         * File Name or Another Node Identifier
         */
        function get value():String;


        /**
         * Label Display
         */
        function get label():String;


        /**
         * Usually File Extension
         */
        function get type():String;


        /**
         * Text to display in the bottom of panel when this node is under the
         * selection caret
         */
        function get info():String;


        /**
         * Get nodes path from the very root to this node, including
         * all nested ITreeProvider-s and null-value nodes.
         * @see INode
         * @return Array of INode
         */
        function getPath():Array;


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
