package ru.koldoon.fc.m.async.interactive {
    import ru.koldoon.fc.m.async.*;

    /**
     * Operation with interaction line
     */
    public interface IInteractiveOperation extends IAsyncOperation {

        function getInteraction():IInteraction;

    }
}
