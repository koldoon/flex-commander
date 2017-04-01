package ru.koldoon.fc.m.tree.impl.fs {
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Progress;
    import ru.koldoon.fc.m.async.progress.IProgress;
    import ru.koldoon.fc.m.tree.INodesBunchOperation;

    public class AbstractNodesBunchOperation extends AbstractAsyncOperation implements INodesBunchOperation {

        public function get nodes():Array {
            return _nodes;
        }


        public function get nodesProcessed():Number {
            return _nodesProcessed;
        }


        public function getProgress():IProgress {
            return progress;
        }


        protected var _nodes:Array;
        protected var _nodesProcessed:Number;
        protected var progress:Progress = new Progress();
    }
}
