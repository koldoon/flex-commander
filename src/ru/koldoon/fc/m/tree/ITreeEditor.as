package ru.koldoon.fc.m.tree {
    public interface ITreeEditor {

        /**
         * Performs on DESTINATION ITreeProvider. Moves Nodes and their associated data
         * to a particular Dir. Basically, this operation can be performed by
         * combination of "copy" and "remove" but for many cases there are much more
         * effective way to move objects in different structures.
         */
        function move():ITreeTransferOperation;


        /**
         * Performs on DESTINATION ITreeProvider. Copy Nodes and their associated data
         * to a particular Dir. Source and Destination Roots are needed to calculate relative
         * path for nodes and their target position
         */
        function copy():ITreeTransferOperation;


        /**
         * Removes nodes and their associated data (files in common)
         */
        function remove():ITreeRemoveOperation;


        /**
         * Create Sub-Directory
         */
        function mkDir():ITreeMkDirOperation;


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
