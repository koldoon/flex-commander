package ru.koldoon.fc.m.popups {
    import flash.display.DisplayObject;

    import mx.core.UIComponent;

    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalAlign;

    /**
     * "dot" styled configurable popup descriptor
     */
    public interface IPopupDescriptor {

        /**
         * Popup instance to show.
         */
        function instance(i:UIComponent):IPopupDescriptor;


        /**
         * This property has no effect when using calloutTo option
         * @param val see spark.layouts.VerticalAlign
         */
        function verticalAlign(val:String = VerticalAlign.MIDDLE):IPopupDescriptor;


        /**
         * This property has no effect when using calloutTo option
         * @param val see spark.layouts.HorizontalAlign
         */
        function horizontalAlign(val:String = HorizontalAlign.CENTER):IPopupDescriptor;


        function marginTop(val:int = 0):IPopupDescriptor;


        function marginBottom(val:int = 0):IPopupDescriptor;


        function marginLeft(val:int = 0):IPopupDescriptor;


        function marginRight(val:int = 0):IPopupDescriptor;


        function margins(val:int = 0):IPopupDescriptor;


        /**
         * Adds "Fog" behind the popup over the application so user
         * can not click and change focus anywhere except the popup.
         */
        function modal(val:Boolean = true):IPopupDescriptor;


        /**
         * Automatically hide popup after given number of seconds
         */
        function hideAfter(seconds:int = 0):IPopupDescriptor;


        /**
         * Hide popup by clicking outside. If <code>false</code> then
         * it will be possible to hide popup by PopupManager.remove() method only,
         * or by <code>hideAfter()</code> option.
         */
        function hideByClickOutside(val:Boolean = true):IPopupDescriptor;


        /**
         * When popup resized, reposition it again according to setup
         */
        function keepPositionOnResize(val:Boolean = true):IPopupDescriptor;


        /**
         * Align popup near some display object.
         */
        function calloutTo(target:DisplayObject):ICalloutDescriptor;


        /**
         * Since popups can be scheduled within the queue, this handler
         * will be executed exactly after popup will be shown
         * @param handler function(popupInstance:*):void
         */
        function onPopupOpen(handler:Function):ICalloutDescriptor;


        /**
         * Executed when popup is hided
         * @param handler function(popupInstance:*):void
         */
        function onPopupClose(handler:Function):ICalloutDescriptor;


        /**
         * Conventional method remove any handlers
         * @param handler
         */
        function removeEventHandler(handler:Function):void;
    }
}
