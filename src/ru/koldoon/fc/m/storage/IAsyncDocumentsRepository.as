package ru.koldoon.fc.m.storage {
    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncValue;
    import ru.koldoon.fc.m.async.IPromise;

    /**
     * Named collection of a documents. Documents can have named indices or
     * auto generated GUID indices (if "push" used)
     */
    public interface IAsyncDocumentsRepository {
        /**
         * Async get item with particular index from the collection
         * @param index
         * @return
         */
        function getDocument(index:String):IAsyncValue;

        /**
         * Set Item at particular index, replaces existing item if it is.
         * @param index
         * @param value
         */
        function putDocument(index:String, value:*):IPromise;

        /**
         * Fetch the documents collection length (all items' indexes count)
         * @return
         */
        function getLength():Number;

        /**
         * Push item to the collection.
         * The item's index is returned in the result operation token when operation
         * is completed successfully.
         *
         * @param value
         * @return
         */
        function pushDocument(value:*):IPromise;

        /**
         * Removes item with a particular index from the collection
         * @param index
         * @return
         */
        function removeDocument(index:String):IPromise;

        /**
         * Clears the collection.
         * @return
         */
        function removeAllDocuments():IPromise;

        /**
         * Selects items from the collection.
         * <code>request</code> filter function is executed over every item and returns
         * <code>true</code> if item fits the conditions.
         *
         * If <code>filter<code> is null then all items will be returned in the result
         * async collection
         *
         * @return
         * @param filter function filter(item:*):Boolean {}
         */
        function selectDocuments(filter:Function = null, limit:Number = Number.MAX_VALUE):IAsyncCollection;

        /**
         * Select indices of the Items corresponding to a filter.
         * Then to get item itself you must use <code>getItem</code> method.
         *
         * @param filter function filter(item:*):Boolean {}
         * @return
         */
        function selectIndices(filter:Function = null):IAsyncCollection;
    }
}
