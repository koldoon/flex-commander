package ru.koldoon.fc.m.tree.impl.fs.cl {
    import ru.koldoon.fc.m.os.CommandLineOperation;

    public class LFS_DiskUsageCLO extends CommandLineOperation {

        /**
         * Get size
         */
        public static const SIZE_RXP:RegExp = /^(\d+)\s+(\/.*)$/;

        override protected function begin():void {
            command("bin/du");
            commandArguments(["-aHk", _path]);

            super.begin();
        }


        override protected function onLines(lines:Array):void {
            for each (var l:String in lines) {

            }
        }


        override protected function onErrorLines(lines:Array):void {

        }


        public function path(value:String):LFS_DiskUsageCLO {
            _path = value;
            return this;
        }


        public function createReferenceNodes(value:Boolean = true):LFS_DiskUsageCLO {
            _createReferenceNodes = value;
            return this;
        }


        private var _path:String;
        private var _totalSizeOnDisk:Number;
        private var _createReferenceNodes:Boolean;
    }
}
