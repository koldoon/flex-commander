package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * Interface describes any operation that returns a particular node as a result.
     */
    public interface ITreeGetNodeOperation extends IAsyncOperation {

        /**
         * Result node
         */
        function getNode():INode;
    }
}
