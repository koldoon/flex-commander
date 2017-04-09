package ru.koldoon.fc.m.storage.impl {
    import flash.display.Shape;
    import flash.events.Event;
    import flash.filesystem.File;

    import mx.utils.UIDUtil;

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.ICollectionPromise;
    import ru.koldoon.fc.m.async.IPromise;
    import ru.koldoon.fc.m.async.IValuePromise;
    import ru.koldoon.fc.m.async.impl.CollectionPromise;
    import ru.koldoon.fc.m.async.impl.Promise;
    import ru.koldoon.fc.m.async.impl.ValuePromise;
    import ru.koldoon.fc.m.storage.IAsyncDocumentsRepository;
    import ru.koldoon.fc.m.storage.impl.disk.LoadObjectOperation;
    import ru.koldoon.fc.m.storage.impl.disk.RemoveObjectOperation;
    import ru.koldoon.fc.m.storage.impl.disk.SaveObjectOperation;

    public class DocumentsRepository implements IAsyncDocumentsRepository {
        public function DocumentsRepository(dir:File) {
            location = dir;
            if (location.exists && !location.isDirectory) {
                throw new Error("Could Not use selected key as a collection. File exists.");
            }

            if (!location.exists) {
                location.createDirectory();
            }

            diskOperationsQueue = new <Function>[];
            diskOperationsInitQueue = new <Function>[];
            docsIndex = new DocumentsIndex();

            pushDiskOperation(function ():IAsyncOperation {
                var op:IAsyncOperation = new LoadObjectOperation(location).name("__COLLECTION_INDEX");
                op.getStatus().onComplete(initCollectionDescriptor);
                return op;

            }, true);
        }


        /**
         * Signal dispatched when the internal operations queue is changed
         */
        public var queueChanged:Signal = new Signal();


        public function getDocument(name:String):IValuePromise {
            var val:ValuePromise = new ValuePromise();
            pushDiskOperation(function ():IAsyncOperation {
                if (documentsCache[name] != null) {
                    val.applyResult(documentsCache[name]);
                }
                else {
                    var op:IAsyncOperation = new LoadObjectOperation(location).name(name);
                    op.getStatus().onComplete(function (op:LoadObjectOperation):void {
                        documentsCache[name] = op.value;
                        val.applyResult(op.value);
                    });
                    return op;
                }
                return null;
            });
            return val;
        }


        public function putDocument(name:String, value:*):IPromise {
            var promise:Promise = new Promise();
            pushDiskOperation(function ():IAsyncOperation {
                documentsCache[name] = value;
                return new SaveObjectOperation(location)
                    .object(name, value)
                    .onStart(function (op:SaveObjectOperation):void {
                        if (!op.getStatus().isUpdating) {
                            docsIndex.files.unshift(name);
                        }
                    })
                    .onComplete(function (op:SaveObjectOperation):void {
                        promise.ready();
                    });
            });
            return promise;
        }


        public function getLength():Number {
            return docsIndex.files.length;
        }


        public function pushDocument(value:*):IPromise {
            return putDocument(UIDUtil.createUID(), value);
        }


        public function removeDocument(name:String):IPromise {
            var promise:IPromise = new Promise();
            pushDiskOperation(function ():IAsyncOperation {
                return new RemoveObjectOperation(location)
                    .name(name)
                    .onResult(function ():void {
                        var fileIndex:int = docsIndex.files.indexOf(name);
                        if (fileIndex >= 0) {
                            docsIndex.files.splice(fileIndex, 1);
                        }
                        delete documentsCache[name];
                        promise.ready();
                    })
                    .onFault(function (o:Object):void {
                        promise.reject();
                    })
            });
            return promise;
        }


        public function removeAllDocuments():IPromise {
            var promise:IPromise = new Promise();
            pushDiskOperation(function ():IAsyncOperation {
                return new ClearDiskLocationOperation(location)
                    .onResult(function ():void {
                        docsIndex.files = [];
                        documentsCache = {};
                    })
                    .onComplete(function (data:Object):void {
                        promise.ready();
                    })
            });
            return promise;
        }


        public function selectDocuments(filter:Function = null, limit:Number = Number.MAX_VALUE):ICollectionPromise {
            var collection:CollectionPromise = new CollectionPromise();
            pushDiskOperation(function ():IAsyncOperation {
                return new SelectDocumentsOperation(location, docsIndex)
                    .filter(filter)
                    .limit(limit)
                    .onComplete(function (op:SelectDocumentsOperation):void {
                        collection.applyResult(op.items);
                    })
            });
            return collection;
        }


        public function selectIndices(filter:Function = null):ICollectionPromise {
            var collection:CollectionPromise = new CollectionPromise();
            pushDiskOperation(function ():IAsyncOperation {
                return new SelectDocumentsIndicesOperation(docsIndex)
                    .filter(filter)
                    .onComplete(function (op:SelectDocumentsIndicesOperation):void {
                        collection.applyResult(op.items);
                    })
            });
            return collection;
        }


        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private var TICKER:Shape = new Shape();
        private var location:File;


        private function initCollectionDescriptor(op:LoadObjectOperation):void {
            if (op.value) {
                docsIndex.files = DocumentsIndex(op.value).files;
            }
            else {
                pushDiskOperation(function ():IAsyncOperation {
                    return new BuildDocumentsIndexOperation(location).index(docsIndex);
                }, true);

                pushDiskOperation(function ():IAsyncOperation {
                    return new SaveObjectOperation(location).object("__COLLECTION_INDEX", docsIndex);
                }, true);
            }
        }


        // -----------------------------------------------------------------------------------
        // Disk Operations
        // -----------------------------------------------------------------------------------

        private var diskOperationsQueue:Vector.<Function>;
        private var diskOperationsInitQueue:Vector.<Function>;
        private var currentAsyncOperation:IAsyncOperation;
        private var docsIndex:DocumentsIndex;


        private function pushDiskOperation(executor:Function, initState:Boolean = false):void {
            if (initState) {
                diskOperationsInitQueue.push(executor);
            }
            else {
                diskOperationsQueue.push(executor);
            }
            TICKER.addEventListener(Event.ENTER_FRAME, processQueue);
        }


        private function processQueue(e:Event = null):void {
            TICKER.removeEventListener(Event.ENTER_FRAME, processQueue);

            if (diskOperationsQueue.length > 0) {
                diskOperationsQueue.push(function ():IAsyncOperation {
                    return new SaveObjectOperation(location).object("__COLLECTION_INDEX", docsIndex);
                });

                processNextDiskOperationsQueue();
            }
        }


        /**
         * Cached documents by items' indices
         * { index : * }
         */
        private var documentsCache:Object = {};


        private function processNextDiskOperationsQueue(e:Event = null):void {
            TICKER.removeEventListener(Event.ENTER_FRAME, processNextDiskOperationsQueue);

            var q:Vector.<Function> = diskOperationsInitQueue.length > 0
                ? diskOperationsInitQueue
                : diskOperationsQueue;

            if (q.length == 0 || currentAsyncOperation) {
                return;
            }

            var executor:Function = q.shift();
            currentAsyncOperation = executor() as IAsyncOperation;

            trace("Executing Async Operation: " + currentAsyncOperation);

            // executor might not return any IAsyncOperation value if it is synchronous
            if (currentAsyncOperation) {
                currentAsyncOperation
                    .execute()
                    .getStatus()
                    .onComplete(function (op:IAsyncOperation):void {
                        currentAsyncOperation = null;
                        TICKER.addEventListener(Event.ENTER_FRAME, processNextDiskOperationsQueue);
                    });
            }
            else {
                TICKER.addEventListener(Event.ENTER_FRAME, processNextDiskOperationsQueue);
            }

            queueChanged.dispatch(q.length);
        }
    }
}
