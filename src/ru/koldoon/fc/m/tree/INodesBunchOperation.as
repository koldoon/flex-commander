package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.progress.IProgressReporter;

    public interface INodesBunchOperation extends IAsyncOperation, IProgressReporter {

        /**
         * Nodes list to process
         */
        function get nodesTotal():Array;


        /**
         * Processed nodesTotal count
         */
        function get nodesProcessed():Number;

    }
}
