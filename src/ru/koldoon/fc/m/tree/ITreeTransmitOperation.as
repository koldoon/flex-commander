package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * Describes the minimum parameters that must have a typical
     * Copy or Move Tree Operation.
     */
    public interface ITreeTransmitOperation extends IAsyncOperation {

        /**
         * Dot style setter.
         * Nodes source directory to calculate copy subtree root
         */
        function setSource(d:IDirectory):ITreeTransmitOperation;


        /**
         * Dot style setter.
         * Nodes subtree target directory.
         */
        function setDestination(d:IDirectory):ITreeTransmitOperation;


        /**
         * Dot style setter.
         * Nodes subtree selector is used to get actual list of nodesTotal
         * to process.
         */
        function setSelector(s:ITreeSelector):ITreeTransmitOperation;
    }
}
