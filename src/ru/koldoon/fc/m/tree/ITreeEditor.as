package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ITreeEditor {

        /**
         * Performs on Destination ITreeProvider. Moves Nodes and their associated data
         * to a particular Dir. Basically, this operation can be performed by
         * combination of "copy" and "remove" but for many cases there are much more
         * effective way to move objects in different structures.
         * @nodes List of INode
         */
        function move(nodes:Array, toDir:IDirectory):IAsyncOperation;


        /**
         * Performs on Destination ITreeProvider. Copy Nodes and their associated data
         * to a particular Dir
         * @nodes List of INode
         */
        function copy(nodes:Array, toDir:IDirectory):IAsyncOperation;


        /**
         * Removes nodes and their associated data (files in common)
         * @param nodes
         * @return
         */
        function remove(nodes:Array):IAsyncOperation;


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
