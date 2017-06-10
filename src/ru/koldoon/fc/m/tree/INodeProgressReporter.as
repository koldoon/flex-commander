package ru.koldoon.fc.m.tree {
    import ru.koldoon.fc.m.progress.IProgress;

    /**
     * Provides currently processing node progress.
     *
     * Some operations does not report an individual
     * nodes processing status, only node name itself.
     * Check for this interface on operation to get status needed.
     */
    public interface INodeProgressReporter {

        function get processingNodeProgress():IProgress;

    }
}
