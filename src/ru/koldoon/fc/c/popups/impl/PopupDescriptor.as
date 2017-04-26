package ru.koldoon.fc.c.popups.impl {
    import flash.display.DisplayObject;

    import mx.core.UIComponent;

    import org.osflash.signals.Signal;

    import ru.koldoon.fc.m.popups.ICalloutDescriptor;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;

    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalAlign;

    public class PopupDescriptor implements IPopupDescriptor, ICalloutDescriptor {

        public var instance_:UIComponent;
        public var verticalAlign_:String = VerticalAlign.MIDDLE;
        public var horizontalAlign_:String = HorizontalAlign.CENTER;
        public var marginTop_:int;
        public var marginBottom_:int;
        public var marginLeft_:int;
        public var marginRight_:int;
        public var modal_:Boolean = true;
        public var hideAfter_:int;
        public var hideByClickOutside_:Boolean;
        public var keepPositionOnResize_:Boolean = true;
        public var anchor:DisplayObject;
        public var position_:Array;
        public var onPopupOpen_:Signal = new Signal();
        public var onPopupClose_:Signal = new Signal();


        /**
         * @inheritDoc
         */
        public function instance(i:UIComponent):IPopupDescriptor {
            instance_ = i;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function verticalAlign(val:String = VerticalAlign.MIDDLE):IPopupDescriptor {
            verticalAlign_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function horizontalAlign(val:String = HorizontalAlign.CENTER):IPopupDescriptor {
            horizontalAlign_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function marginTop(val:int = 0):IPopupDescriptor {
            marginTop_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function marginBottom(val:int = 0):IPopupDescriptor {
            marginBottom_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function marginLeft(val:int = 0):IPopupDescriptor {
            marginLeft_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function marginRight(val:int = 0):IPopupDescriptor {
            marginRight_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function margins(val:int = 0):IPopupDescriptor {
            marginBottom_ = marginTop_ = val;
            marginLeft_ = marginRight_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function modal(val:Boolean = true):IPopupDescriptor {
            modal_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function hideAfter(seconds:int = 0):IPopupDescriptor {
            hideAfter_ = seconds;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function hideByClickOutside(val:Boolean = true):IPopupDescriptor {
            hideByClickOutside_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function keepPositionOnResize(val:Boolean = true):IPopupDescriptor {
            keepPositionOnResize_ = val;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function calloutTo(anchor:DisplayObject):ICalloutDescriptor {
            this.anchor = anchor;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function position(priorities:Array):ICalloutDescriptor {
            position_ = priorities;
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onPopupOpen(handler:Function):ICalloutDescriptor {
            onPopupOpen_.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function onPopupClose(handler:Function):ICalloutDescriptor {
            onPopupClose_.add(handler);
            return this;
        }


        /**
         * @inheritDoc
         */
        public function removeEventHandler(handler:Function):void {
            onPopupClose_.remove(handler);
            onPopupOpen_.remove(handler);
        }
    }
}
