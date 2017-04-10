package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * Describes the minimum parameters that must have a typical
     * Remove Tree Operation.
     */
    public interface ITreeRemoveOperation extends IAsyncOperation {

        /**
         * Nodes to remove
         * @param list Array of INode to remove
         */
        function setNodes(list:Array):ITreeRemoveOperation;

    }
}
