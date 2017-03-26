package ru.koldoon.fc.m.app {

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.popups.IPopupManager;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;

    public interface IPanel {

        /**
         * Current Panel Directory Node
         */
        function get directory():IDirectory;


        /**
         *
         * @param val Directory to show
         */
        function set directory(val:IDirectory):void;


        /**
         * Read current directory nodes again
         */
        function refresh():void;


        /**
         * Manage Panel selection
         */
        function get selection():INodesSelection;


        /**
         * Node under user caret. If null - no caret is present,
         * means that this Panel is a Target.
         * Setting selected node will cause list to scroll to it
         * if it's not currently visible
         */
        function get selectedNode():INode;


        function set selectedNode(node:INode):void;


        /**
         * Note: Selected node by this index may be different from
         * item from <code>directory.items</code> list's node under this
         * index because of panel sorting.
         */
        function get selectedNodeIndex():int;


        function set selectedNodeIndex(val:int):void;


        function get selectedNodeChange():Signal;


        /**
         * Standard enabled/disabled property. When panel is disabled
         * it can not receive focus and mouse/keyboard interaction
         * Also, often disabled panel alpha is set to 0.5
         */
        function get enabled():Boolean;


        function set enabled(val:Boolean):void;


        function get active():Boolean;


        function set active(val:Boolean):void;


        /**
         * Panel level PopupManager. Popups can be aligned within
         * Panel only (up to replace all its content)
         */
        function get popupManager():IPopupManager;


        /**
         * Set Text do display in the bottom of the panel
         * @param txt
         */
        function setStatusText(txt:String):void;
    }
}
