package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * Describes the minimum parameters that must have a typical
     * Copy or Move Tree Operation.
     */
    public interface ITreeTransferOperation extends IAsyncOperation {

        /**
         * Dot style setter.
         * Nodes source directory to calculate copy subtree root
         */
        function setSource(d:IDirectory):ITreeTransferOperation;


        /**
         * Dot style setter.
         * Nodes subtree target directory.
         */
        function setDestination(d:IDirectory):ITreeTransferOperation;


        /**
         * List of Nodes to transfer
         */
        function setSourceNodes(list:Array):ITreeTransferOperation;

    }
}
