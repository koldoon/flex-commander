package ru.koldoon.fc.m.storage {
    public interface IStorage {
        /**
         * Get Async collection entry with methods and properties to work with a collection
         * @param key Some ID of the collection.
         * @return
         */
        function getDocumentsRepository(key:*):IAsyncDocumentsRepository;
    }
}
