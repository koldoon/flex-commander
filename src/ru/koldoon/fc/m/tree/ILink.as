package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ILink extends INode {

        /**
         * Target node this link points to.
         * Before link is resolved the value is "null".
         * Call <code>resolve()</code> operation to get target node.
         * After resolving target can have any INode value,
         * including its descendants, such as IDirectory and ILink.
         */
        function get target():INode;


        /**
         * Async operation for resolving link into
         * real INode object.
         */
        function resolve():IAsyncOperation;
    }
}
