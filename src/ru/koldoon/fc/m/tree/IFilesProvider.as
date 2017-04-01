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
         * Get file system objects references (files and directories) to be able to perform standard operations
         * if operations of copy/move/remove are performed between different ITreeProviders.
         *
         * @param nodes List of INode
         * @param followLinks follow to link if target path is a link. Intermediate links are always followed
         * @return Collection of FileSystemReference
         */
        function getFiles(nodes:Array, followLinks:Boolean = true):IAsyncCollection;


        /**
         * Put Files in particular directory in a tree provider.
         * Source files must not be modified during this operation.
         * To move, delete or copy nodes use ITreeEditor interface within TreeProvider.
         */
        function putFiles(files:FileSystemReference, toDir:IDirectory):IAsyncOperation;


        /**
         * Purge any temporary files created.
         */
        function purge():IAsyncOperation;

    }
}
