package ru.koldoon.fc.m.async.impl {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractionMessage;

    public class Interaction implements IInteraction {

        /**
         * @inheritDoc
         */
        public function getMessage():IInteractionMessage {
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


        public function setMessage(msg:IInteractionMessage):void {
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
            listeningSource.onMessage(onSourceMessage);
            return this;
        }


        private function onSourceMessage(i:IInteraction):void {
            setMessage(i.getMessage());
        }


        private var _message:IInteractionMessage;
        private var _onMessage:Signal = new Signal();
        private var listeningSource:IInteraction;
    }
}
