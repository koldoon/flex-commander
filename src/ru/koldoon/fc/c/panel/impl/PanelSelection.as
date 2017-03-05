package ru.koldoon.fc.c.panel.impl {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.app.INodesSelection;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;

    public class PanelSelection extends EventDispatcher implements INodesSelection {
        public function PanelSelection() {
            selectedNodesIndex = new Dictionary(true);
            change_ = new Signal();
        }


        /**
         * @inheritDoc
         */
        public function get change():Signal {
            return change_;
        }


        /**
         * @inheritDoc
         */
        [Bindable(event="lengthChange")]
        public function get length():Number {
            return length_;
        }


        /**
         * @inheritDoc
         */
        public function isSelected(node:INode):Boolean {
            return selectedNodesIndex[node];
        }


        /**
         * @inheritDoc
         */
        public function add(node:INode):void {
            if (isSelected(node) || node == AbstractNode.PARENT_NODE) {
                return;
            }
            selectedNodesIndex[node] = true;
            length_ += 1;
            change.dispatch();
            dispatchEvent(new Event("lengthChange"));
        }


        /**
         * @inheritDoc
         */
        public function remove(node:INode):void {
            if (!isSelected(node)) {
                return;
            }
            delete selectedNodesIndex[node];
            length_ -= 1;
            change.dispatch();
            dispatchEvent(new Event("lengthChange"));
        }


        /**
         * @inheritDoc
         */
        public function reset():void {
            selectedNodesIndex = new Dictionary(true);
            length_ = 0;
            change.dispatch();
            dispatchEvent(new Event("lengthChange"));
        }


        /**
         * @inheritDoc
         */
        public function invert(node:INode):void {
            if (isSelected(node)) {
                remove(node);
            }
            else {
                add(node);
            }
        }


        /**
         * @inheritDoc
         */
        public function getSelectedNodes():Array {
            var list:Array = [];
            for (var node:* in selectedNodesIndex) {
                list.push(node);
            }
            return list;
        }


        private var selectedNodesIndex:Dictionary;
        private var change_:Signal;
        private var length_:int;

    }
}
