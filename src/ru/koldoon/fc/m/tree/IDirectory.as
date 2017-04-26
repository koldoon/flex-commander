package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * Common Nodes Directory interface.
     * Directory can contain another nodes.
     */
    public interface IDirectory extends INode {

        /**
         * Items loaded by last <code>getListing()</code> operation
         * @return
         */
        function get nodes():Array;


        /**
         * This method mostly provided by ITreeProvider interface,
         * here just a link to it through IDirectory reference.
         * Basically, you need to go to root using <code>parent</code>
         * property to find ITreeProvider instance.
         * After operation is complete, nodes property is updated with
         * new items.
         */
        function refresh():IAsyncOperation;
    }
}
