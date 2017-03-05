package ru.koldoon.fc.m.storage.impl.sync {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    /**
     * Simple Class to work with filesystem in SYNCHRONOUS way.
     */
    public class FS {
        private static var instance:FS;

        public static function getInstance():FS {
            if (!instance) {
                instance = new FS();
            }
            return instance;
        }

        /**
         * Save raw bytes to file
         * @param file
         * @param value
         */
        public function saveBytes(file:File, value:ByteArray):void {
            try {
                if (file.exists) {
                    file.deleteFile();
                }
            }
            catch (error:Error) {
            }

            if (!value) {
                return;
            }

            try {
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.WRITE);
                fs.writeBytes(value);
                fs.close();
            }
            catch (error:Error) {
            }
        }

        /**
         * Load raw bytes from file
         * @param file
         * @return
         */
        public function loadBytes(file:File):ByteArray {
            try {
                if (file.isDirectory || !file.exists) {
                    return null;
                }
            }
            catch (error:Error) {
            }

            try {
                var fs:FileStream = new FileStream();
                var ba:ByteArray = new ByteArray();

                fs.open(file, FileMode.READ);
                fs.readBytes(ba);

                return ba;
            }
            catch (error:Error) {
                return null;
            }

            return null;
        }
    }
}
