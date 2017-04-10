package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.async.IAsyncOperation;

    public interface ITreeMkDirOperation extends IAsyncOperation {

        /**
         * Dot style setter.
         * Nodes source directory to calculate copy subtree root
         */
        function setParent(d:IDirectory):ITreeMkDirOperation;


        /**
         * New Directory name.
         */
        function setName(n:String):ITreeMkDirOperation;

    }
}
