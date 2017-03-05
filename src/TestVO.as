package {
    [RemoteClass]
    public class TestVO {

        public function TestVO(str:String = null, int1:int = 0, number:Number = 5) {
            this.str = str;
            this.int1 = int1;
            this.number = number;
            this.date = new Date(1987, 0, 11);
        }


        public var str:String;
        public var int1:int;
        public var number:Number;
        public var date:Date;

    }
}
