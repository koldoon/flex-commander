package ru.koldoon.fc.m.interactive.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.interactive.IInteraction;
    import ru.koldoon.fc.m.interactive.IMessage;

    public class Interaction implements IInteraction {

        /**
         * @inheritDoc
         */
        public function getMessage():IMessage {
            return _message;
        }


        /**
         * @inheritDoc
         */
        public function onMessage(f:Function):IInteraction {
            _onMessage.add(f);
            return this;
        }


        public function removeEventListener(h:Function):void {
            _onMessage.remove(h);
        }


        public function setMessage(msg:IMessage):void {
            _message = msg;
            _onMessage.dispatch(this);
        }


        public function dispose():void {
            _onMessage.removeAll();
            _message = null;
            listeningSource = null;
        }


        public function listenTo(anotherInteraction:IInteraction):IInteraction {
            if (listeningSource) {
                listeningSource.removeEventListener(onSourceMessage);
            }
            listeningSource = anotherInteraction;
            if (listeningSource) {
                listeningSource.onMessage(onSourceMessage);
            }
            return this;
        }


        private function onSourceMessage(i:IInteraction):void {
            setMessage(i.getMessage());
        }


        private var _message:IMessage;
        private var _onMessage:Signal = new Signal();
        private var listeningSource:IInteraction;
    }
}
