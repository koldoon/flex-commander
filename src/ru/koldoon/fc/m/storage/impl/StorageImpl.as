package ru.koldoon.fc.m.storage.impl {
    import flash.filesystem.File;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.storage.IAsyncDocumentsRepository;
    import ru.koldoon.fc.m.storage.IStorage;

    [ExcludeClass]
    public class StorageImpl implements IStorage {
        public function StorageImpl(location:File) {
            this.location = location;
        }

        // -----------------------------------------------------------------------------------
        // IStorage
        // -----------------------------------------------------------------------------------

        public function getDocumentsRepository(key:*):IAsyncDocumentsRepository {
            var documentsDirName:String = getFileName(key);

            if (!documents[documentsDirName]) {
                var location:File = location.resolvePath("documents").resolvePath(documentsDirName);
                documents[documentsDirName] = new DocumentsRepository(location);
            }

            return documents[documentsDirName];
        }

        // -----------------------------------------------------------------------------------
        // Private
        // -----------------------------------------------------------------------------------

        private var location:File;
        private var documents:Object = {};

        private function getFileName(key:*):String {
            var name:String;
            if (key is String) {
                name = key;
            }
            else if (key is Class) {
                name = ClassInfo.forClass(key).simpleName;
            }
            else {
                name = ClassInfo.forInstance(key).simpleName;
            }
            return name;
        }
    }
}
