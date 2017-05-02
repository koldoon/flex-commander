package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    /**
     * ITreeProvider is the main class that provides nodes tree structure.
     * INodes lists are always grouped by IDirectory objects.
     * Provider itself can be a node inside tree structure in cases
     * where nodes can be opened by another nested tree providers.
     *
     * Typical path string:
     * <i>/Users/user/dir/archfile.zip:/subdir/document.doc</i>
     *
     * Symbol ":" is used to split path into parts where different ITreeProvider-s are used.
     * By default, if no tree provider is defined, "fs" (File System) is used:
     * <i>fs:/Users/dir/...<i>
     */
    public interface ITreeProvider extends INode {
        /**
         * ITreeProvider itself don't have to realize IDirectory interface,
         * in this case it creates IDirectory root node and returns it.
         * If it realizes IDirectory (which is not recommended) this method
         * should return provider itself.
         */
        function getRootDirectory():IDirectory;


        /**
         * Gets INode by path string.
         * This method generates all nodes from path sequence to
         * keep tree consistency and returns the target node instance.
         *
         * Example:
         * "/Users/user/dir/archfile.zip:/subdir/document.doc" resolves into:
         * TP_DIR:FS <- DIR:Users <- DIR:user <- DIR:dir <- NODE:archfile.zip <- TP_DIR:ZIP <- DIR:subdir <- NODE:document.doc
         *
         * TP_DIR is ITreeProvider & IDirectory because the root directory is ofter TreeProvider itself.
         *
         * To get correct tree sequence this method can ask for nodes tree in subsequent
         * TreeProviders, so it's implementation is often recursive.
         */
        function resolvePathString(path:String):ITreeGetNodeOperation;


        /**
         * Returns async collection of INode items
         */
        function getDirectoryListing(dir:IDirectory):IAsyncOperation;


        /**
         * Resolves link node: fill in its <code>target</code> property
         * with concrete node or null if resolving is impossible
         */
        function resolveLink(lnk:ILink):IAsyncOperation;
    }
}
