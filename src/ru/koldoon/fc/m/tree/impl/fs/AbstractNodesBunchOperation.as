package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.impl.AbstractProgressiveAsyncOperation;
    import ru.koldoon.fc.m.tree.INode;

    public class AbstractNodesBunchOperation extends AbstractProgressiveAsyncOperation {

        /**
         * Total nodes on queue to process
         */
        public var nodesTotal:int;

        /**
         * Nodes already processed count
         */
        public var nodesProcessed:int;

        /**
         * Total nodes' size in bytes. Directories are not included,
         * we take them as zero-sized objects
         */
        public var bytesTotal:int;

        /**
         * Total bytes of nodes processed.
         */
        public var bytesProcessed:int;

        /**
         * Currently being processed node.
         */
        public var currentNode:INode;
    }
}
