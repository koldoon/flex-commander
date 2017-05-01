package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ITreeResolvePathOperation extends IAsyncOperation {

        /**
         * Result node
         */
        function getNode():INode;
    }
}
