package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.ICollectionPromise;

    public interface ITreeProvider extends INode {

        /**
         * Returns async collection of INode items
         * @return
         */
        function getListingFor(dir:IDirectory):ICollectionPromise;


        /**
         * ITreeProvider itself don't have to realize IDirectory interface,
         * in this case it creates IDirectory root node and returns it.
         * If it realizes IDirectory (which is not recommended) this method
         * should return provider itself.
         * @return Root directory node
         */
        function getRootDirectory():IDirectory;
    }
}
