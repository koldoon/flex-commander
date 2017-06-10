package ru.koldoon.fc.m.interactive.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.interactive.ISelectOptionMessage;

    public class SelectOptionMessage extends Message implements ISelectOptionMessage {
        /**
         * @inheritDoc
         */
        public function get options():Array {
            return _options;
        }


        public function responseOptions(ops:Array):SelectOptionMessage {
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


        public function get type():String {
            return _type;
        }


        public function onResponse(f:Function):SelectOptionMessage {
            _onResponse.addOnce(f);
            return this;
        }


        private var _type:String;
        private var _options:Array;
        private var _onResponse:Signal = new Signal();

    }
}
