package ru.koldoon.fc.m.async {
    import mx.collections.ArrayCollection;

    /**
     * Async Collection Promise
     */
    public interface IAsyncCollection extends IPromise {

        function get items():ArrayCollection;

    }
}
