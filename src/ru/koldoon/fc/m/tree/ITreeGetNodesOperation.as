package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * This Interface describes operations that return a nodes list as a result
     */
    public interface ITreeGetNodesOperation extends IAsyncOperation {

        /**
         * Result List of INodes (IDirectories as well)
         * @see INode
         */
        function getNodes():Array;

    }
}
