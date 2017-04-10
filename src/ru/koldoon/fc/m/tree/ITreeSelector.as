package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * This interface is provided the way to get nodesTotal
     * list in some parametrized way. Used as async nodesTotal
     * provider for such operations like "copy", "move", etc.
     *
     * Selector was introduced because of complexity of params of
     * nodesTotal selection for different ITreeProvider-s
     */
    public interface ITreeSelector extends IAsyncOperation {

        function get nodes():Array;

    }
}
