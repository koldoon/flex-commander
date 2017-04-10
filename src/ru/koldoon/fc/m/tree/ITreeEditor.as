package ru.koldoon.fc.m.tree {
    public interface ITreeEditor {

        /**
         * Performs on DESTINATION ITreeProvider. Moves Nodes and their associated data
         * to a particular Dir. Basically, this operation can be performed by
         * combination of "copy" and "remove" but for many cases there are much more
         * effective way to move objects in different structures.
         */
        function move():ITreeTransmitOperation;


        /**
         * Performs on DESTINATION ITreeProvider. Copy Nodes and their associated data
         * to a particular Dir. Source and Destination Roots are needed to calculate relative
         * path for nodesTotal and their target position
         */
        function copy():ITreeTransmitOperation;


        /**
         * Removes nodesTotal and their associated data (files in common)
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
         * |                                       +---------------------------<- copy (nodesTotal, /SomeDir) +
         * |                                       - repackArchive()                ^
         * +--------------<- putFiles(file.zip, /) +                                perform getFiles() from source ITreeEditor
         *
         *                             when to remove local file.zip ?
         *
         *
         *  src:nodesTotal   |   dst:dir
         *  if src TrPr == dst TrPr && TrPr impl. ITreeEditor -> TrPr.(copy/move/remove)...
         *
         */
    }
}
