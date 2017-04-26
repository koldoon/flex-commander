package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ITreeProvider extends INode {
        /**
         * ITreeProvider itself don't have to realize IDirectory interface,
         * in this case it creates IDirectory root node and returns it.
         * If it realizes IDirectory (which is not recommended) this method
         * should return provider itself.
         */
        function getRootDirectory():IDirectory;


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
