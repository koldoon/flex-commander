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
         * @return
         */
        function verticalAlign(val:String = VerticalAlign.MIDDLE):IPopupDescriptor;


        /**
         * This property has no effect when using calloutTo option
         * @param val see spark.layouts.HorizontalAlign
         * @return
         */
        function horizontalAlign(val:String = HorizontalAlign.CENTER):IPopupDescriptor;


        function marginTop(val:int = 0):IPopupDescriptor;


        function marginBottom(val:int = 0):IPopupDescriptor;


        function marginLeft(val:int = 0):IPopupDescriptor;


        function marginRight(val:int = 0):IPopupDescriptor;


        function margins(val:int = 0):IPopupDescriptor;


        /**
         * Wait until all previous popups are closed. Recommended behaviour
         * for the most of cases.
         * @default true
         * @param val
         * @return
         */
        function inQueue(val:Boolean = true):IPopupDescriptor;


        /**
         * Adds "Fog" behind the popup over the application so user
         * can not click and change focus anywhere except the popup.
         * @param val
         * @return
         */
        function modal(val:Boolean = true):IPopupDescriptor;


        /**
         * Automatically hide popup after given number of seconds
         * @param seconds
         * @return
         */
        function hideAfter(seconds:int = 0):IPopupDescriptor;


        /**
         * Hide popup by clicking outside. If <code>false</code> then
         * it will be possible to hide popup by PopupManager.remove() method only,
         * or by <code>hideAfter()</code> option.
         * @param val
         * @return
         */
        function hideByClickOutside(val:Boolean = true):IPopupDescriptor;


        /**
         * Align popup near some display object.
         * @param target
         * @return
         */
        function calloutTo(target:DisplayObject):ICalloutDescriptor;


        /**
         * Since popups can be scheduled within the queue, this handler
         * will be executed exactly after popup will be shown
         * @param handler function(popupInstance:*):void
         * @param unset
         */
        function onPopupOpen(handler:Function, unset:Boolean):ICalloutDescriptor;


        /**
         * Executed when popup is hided
         * @param handler function(popupInstance:*):void
         * @param unset
         */
        function onPopupClose(handler:Function, unset:Boolean):ICalloutDescriptor;
    }
}
