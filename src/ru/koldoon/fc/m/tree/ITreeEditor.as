package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ITreeEditor {

        /**
         * Performs on DESTINATION ITreeProvider. Moves Nodes and their associated data
         * to a particular Dir. Basically, this operation can be performed by
         * combination of "copy" and "remove" but for many cases there are much more
         * effective way to move objects in different structures.
         */
        function move(source:IDirectory, destination:IDirectory, selector:ITreeSelector):IAsyncOperation;


        /**
         * Performs on DESTINATION ITreeProvider. Copy Nodes and their associated data
         * to a particular Dir. Source and Destination Roots are needed to calculate relative
         * path for nodes and their target position
         * @param source Source nodes subtree ROOT.
         * @param destination Target directory ROOT.
         * @param selector Nodes list async selector
         */
        function copy(source:IDirectory, destination:IDirectory, selector:ITreeSelector):IAsyncOperation;


        /**
         * Removes nodes and their associated data (files in common)
         * @param nodes
         */
        function remove(nodes:Array):IAsyncOperation;


        /**
         * Create Sub-Directory
         */
        function createDirectory(name:String, parent:IDirectory):IAsyncOperation;


        /***
         * SSHTreeProvider -> (/) -> (file.zip) -> ZipTreeProvider (file.zip) -> (/) -> (/SomeDir) :: [ Copy File To Archive ]
         * ^                                       v
         * +-----------------<- getFiles(file.zip) +                                                     |
         * |                                       +---------------------------<- copy (nodes, /SomeDir) +
         * |                                       - repackArchive()                ^
         * +--------------<- putFiles(file.zip, /) +                                perform getFiles() from source ITreeEditor
         *
         *                             when to remove local file.zip ?
         *
         *
         *  src:nodes   |   dst:dir
         *  if src TrPr == dst TrPr && TrPr impl. ITreeEditor -> TrPr.(copy/move/remove)...
         *
         */
    }
}
