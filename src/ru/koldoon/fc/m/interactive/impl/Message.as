package ru.koldoon.fc.m.interactive.impl {
    import ru.koldoon.fc.m.interactive.IMessage;

    public class Message implements IMessage {
        /**
         * @inheritDoc
         */
        public function get text():String {
            return _text;
        }


        public function setText(value:String):Message {
            _text = value;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function get data():* {
            return _data;
        }


        public function setData(value:*):Message {
            _data = value;
            return this;
        }


        private var _text:String;
        private var _data:*;

    }
}
