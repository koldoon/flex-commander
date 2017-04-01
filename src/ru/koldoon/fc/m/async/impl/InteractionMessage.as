package ru.koldoon.fc.m.async.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.interactive.IInteractionMessage;

    public class InteractionMessage implements IInteractionMessage {
        public function InteractionMessage(type:String) {
            _type = type;
        }


        /**
         * @inheritDoc
         */
        public function get options():Array {
            return _options;
        }


        public function responseOptions(ops:Array):InteractionMessage {
            _options = ops;
            return this;

        }


        /**
         * @inheritDoc
         */
        public function response(option:* = null):void {
            _onResponse.dispatch(option);
            _onResponse.removeAll();
        }


        /**
         * @inheritDoc
         */
        public function get text():String {
            return _text;
        }


        public function setText(value:String):InteractionMessage {
            _text = value;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function get data():* {
            return _data;
        }


        public function setData(value:*):InteractionMessage {
            _data = value;
            return this;
        }


        public function get type():String {
            return _type;
        }


        public function onResponse(f:Function):InteractionMessage {
            _onResponse.addOnce(f);
            return this;
        }


        private var _text:String;
        private var _data:*;
        private var _type:String;
        private var _options:Array;
        private var _onResponse:Signal = new Signal();

    }
}
