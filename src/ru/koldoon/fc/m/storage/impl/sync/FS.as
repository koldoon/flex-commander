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
        public function writeBytes(file:File, value:ByteArray):void {
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
         */
        public function readBytes(file:File):ByteArray {
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


        /**
         * Load string from external file
         * @param file
         */
        public function readString(file:File):String {
            var ba:ByteArray = readBytes(file);
            if (ba) {
                return ba.readUTFBytes(ba.bytesAvailable);
            }
            return null;
        }

        /**
         * Write string to external file
         * @param file
         */
        public function writeString(file:File, str:String):void {
            var ba:ByteArray = new ByteArray();
            ba.writeUTFBytes(str);
            writeBytes(file, ba);
        }

    }
}
