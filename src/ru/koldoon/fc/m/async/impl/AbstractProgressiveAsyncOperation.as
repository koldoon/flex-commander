package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.IProgress;
    import ru.koldoon.fc.m.async.IProgressReporter;

    public class AbstractProgressiveAsyncOperation extends AbstractAsyncOperation implements IProgressReporter {

        protected var progress_:Progress = new Progress();

        public function get progress():IProgress {
            return progress_;
        }
    }
}
