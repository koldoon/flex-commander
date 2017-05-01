package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * This interface provides the way to get flat nodes
     * list in some (parametrized) way. Used as async nodes
     * provider for such operations like "copy", "move", etc.
     *
     * Selector was introduced because of complexity of params of
     * nodes selection for different ITreeProvider-s
     */
    public interface ITreeSelector extends IAsyncOperation {

        /**
         * Result List of INodes (IDirectories as well)
         * @see INode
         */
        function getNodes():Array;

    }
}
