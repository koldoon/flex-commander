package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.async.impl.AbstractAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Progress;
    import ru.koldoon.fc.m.async.progress.IProgress;
    import ru.koldoon.fc.m.tree.INodesBatchOperation;

    public class AbstractNodesBunchOperation extends AbstractAsyncOperation implements INodesBatchOperation {

        /**
         * @inheritDoc
         */
        public function get nodesQueue():Array {
            return _nodesQueue;
        }


        /**
         * @inheritDoc
         */
        public function get processingNodeIndex():Number {
            return _processingNodeIndex;
        }


        /**
         * @inheritDoc
         */
        public function get progress():IProgress {
            return _progress;
        }


        protected var _nodesQueue:Array;
        protected var _processingNodeIndex:Number;
        protected var _progress:Progress = new Progress();
    }
}
