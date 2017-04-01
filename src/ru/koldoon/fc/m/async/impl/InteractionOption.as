package ru.koldoon.fc.m.async.impl {
    public class InteractionOption {

        public function InteractionOption(value:String, label:String, context:* = null) {
            this.label = label;
            this.value = value;
            this.context = context;
        }


        public var label:String;
        public var value:String;

        /**
         * Any data connected to this option except value
         */
        public var context:*;
    }
}
