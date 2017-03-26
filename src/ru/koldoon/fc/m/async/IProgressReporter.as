package ru.koldoon.fc.m.async {
    /**
     * This interface defines class that can report it's progress
     * via message or percent value.
     */
    public interface IProgressReporter {

        function get progress():IProgress;

    }
}
