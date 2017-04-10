package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;

    public interface INodesBunchOperation extends IAsyncOperation, IProgressReporter {

        /**
         * Nodes list to process
         */
        function get nodes():Array;


        /**
         * Processed nodes count
         */
        function get nodesProcessed():Number;

    }
}