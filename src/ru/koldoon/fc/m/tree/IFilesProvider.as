package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;

    /**
     * This interface is intended to provide a "bridge" between different ITreeProviders through
     * File System Files ad Directories references.
     */
    public interface IFilesProvider {

        /**
         * For Source ITreeProvider.
         * Get file system objects references (files and filters) to be able to perform standard operations
         * if operations of copy/move/remove are performed between different ITreeProviders.
         *
         * @param nodes List of INode
         * @return Collection of FileSystemReference
         */
        function getFiles(nodes:Array):IAsyncCollection;


        /**
         * Put Files in particular directory in a tree provided.
         * Source files must not be modified during this operation.
         * To move, delete or copy files use ITreeEditor interface within FileSystemTreeProvider.
         */
        function putFiles(files:FileSystemReference, toDir:IDirectory):IAsyncOperation;


        /**
         * Purge any temporary files created.
         */
        function purge():IAsyncOperation;

    }
}
