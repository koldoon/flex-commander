package ru.koldoon.fc.m.async.progress {
    /**
     * This interface defines class that can report it's progress
     * via message or percent value.
     */
    public interface IProgressReporter {

        /**
         * IProgress object, that represents current processing completeness
         */
        function get progress():IProgress;

    }
}
