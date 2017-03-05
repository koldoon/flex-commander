package ru.koldoon.fc.m.storage.impl {
    import flash.filesystem.File;

    import ru.koldoon.fc.m.storage.IStorage;

    public class Storage {
        /**
         * You can configure basedir before the first storage usage
         */
        public static var BASE_DIR:File = File.documentsDirectory.resolvePath(".storage");

        /**
         * Fabric method for storage accessor
         * @param key
         * @return
         */
        public static function getStorage(key:String = "main"):IStorage {
            if (!index[key]) {
                index[key] = new StorageImpl(BASE_DIR.resolvePath(key));
            }

            return index[key];
        }

        private static var index:Object = {};

    }
}
