package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;

    /**
     * Provides common contract to get overall nodes list to process
     * and currently processing node.
     *
     * If you need a currently processing node progress, check for
     * INodeProgressReporter interface
     */
    public interface INodesBatchOperation extends IAsyncOperation, IProgressReporter {

        /**
         * INodes list to process
         * @return Array of INode
         */
        function get nodesQueue():Array;


        /**
         * Use this property to get particular node from
         * <code>nodes</code> list;
         */
        function get processingNodeIndex():Number;

    }
}
