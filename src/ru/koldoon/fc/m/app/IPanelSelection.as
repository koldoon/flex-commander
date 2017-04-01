package ru.koldoon.fc.m.app {
    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.tree.INode;

    /**
     * Manages Panel Selected Nodes
     */
    public interface IPanelSelection {

        /**
         * Check if particular node is selected
         */
        function isSelected(node:INode):Boolean;


        /**
         * Add node to selection.
         */
        function add(node:INode):void;


        /**
         * Remove node from selection
         */
        function remove(node:INode):void;


        /**
         * Invert node's selection.
         */
        function invert(node:INode):void;


        /**
         * Remove any selected nodes.
         */
        function reset():void;


        /**
         * Get list of all selected nodes
         */
        function getSelectedNodes():Array;


        /**
         * Gel selected nodes count.
         */
        function get length():Number;


        /**
         * Dispatched when selection is changed.
         */
        function get change():Signal;
    }
}
