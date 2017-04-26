package ru.koldoon.fc.c.popups.impl {
    import com.greensock.TweenLite;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;

    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    import mx.events.CloseEvent;
    import mx.events.ResizeEvent;
    import mx.graphics.SolidColor;

    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.popups.IPopupManager;

    import spark.components.Group;
    import spark.layouts.HorizontalAlign;
    import spark.layouts.VerticalAlign;
    import spark.primitives.Rect;

    public class PopupManager extends Group implements IPopupManager {
        public function PopupManager() {
            clipAndEnableScrolling = true;
            calloutArranger = new CalloutArranger(this);
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }


        override protected function createChildren():void {
            super.createChildren();

            fogLayer = new Group();
            fogLayer.left = fogLayer.right = 0;
            fogLayer.top = fogLayer.bottom = 0;
            fogLayer.addEventListener(MouseEvent.MOUSE_DOWN, onFogMouseDown);

            var fogFill:Rect = new Rect();
            fogFill.left = fogFill.right = 0;
            fogFill.top = fogFill.bottom = 0;
            fogFill.fill = new SolidColor(0, 0.25);

            fogLayer.addElement(fogFill);
        }


        public function add():IPopupDescriptor {
            var pd:PopupDescriptor = new PopupDescriptor();
            addToQueue(pd);
            return pd;
        }


        public function remove(pd:IPopupDescriptor = null):void {
            if (popupsVisible.indexOf(pd) != -1) {
                removePopupVisible(pd)
            }
            else {
                var qi:int = displayQueue.indexOf(pd);
                if (qi != -1) {
                    displayQueue.splice(qi, 1);
                }
            }
        }


        [Bindable(event="popupsChange")]
        public function getPopupsVisible():Vector.<IPopupDescriptor> {
            return popupsVisible;
        }


        public function getQueue():Vector.<IPopupDescriptor> {
            return displayQueue;
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        /**
         * Popups that was added in the same frame and waiting to be added on stage
         */
        private var displayQueue:Vector.<IPopupDescriptor> = new Vector.<IPopupDescriptor>();
        private var popupsVisible:Vector.<IPopupDescriptor> = new Vector.<IPopupDescriptor>();
        private var fogLayer:Group;
        private var calloutArranger:CalloutArranger;
        private var popupsClicked:Dictionary = new Dictionary(true);
        private var modalPopupsVisible:int = 0;
        private var focusedObjectBehind:UIComponent;


        private function onFogMouseDown(event:MouseEvent):void {
            event.stopPropagation();
            onStageMouseDown(event);
        }


        private function onAddedToStage(event:Event):void {
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
        }


        private function addToQueue(p:PopupDescriptor):void {
            displayQueue.push(p);
            addEventListener(Event.ENTER_FRAME, processQueue);
        }


        private function processQueue(e:Event):void {
            removeEventListener(Event.ENTER_FRAME, processQueue);
            if (displayQueue.length == 0) {
                return;
            }

            var pd:PopupDescriptor = PopupDescriptor(displayQueue.shift());
            popupsVisible.push(pd);
            dispatchEvent(new Event("popupsChange"));

            // put popup at right z-index
            if (pd.modal_) {
                if (!modalPopupsVisible) {
                    // if this is the first modal popup
                    focusedObjectBehind = focusManager.getFocus() as UIComponent || stage.focus as UIComponent;
                }

                modalPopupsVisible += 1;
                if (!containsElement(fogLayer)) {
                    addElement(fogLayer);
                }

                // temporary hide other modal popups
                var fogIndex:int = getElementIndex(fogLayer);
                for (var i:int = fogIndex + 1; i < numElements; i++) {
                    var elem:IVisualElement = getElementAt(i);
                    elem.visible = false;
                    elem.removeEventListener(FocusEvent.FOCUS_OUT, onModalPopupFocusOut);
                }

                addElement(pd.instance_);
            }
            else {
                if (containsElement(fogLayer)) {
                    // before fog
                    addElementAt(pd.instance_, getElementIndex(fogLayer));
                }
                else {
                    addElement(pd.instance_);
                }
            }

            pd.instance_.visible = false;

            TweenLite.to(this, 0, {
                delay:      2,
                useFrames:  true,
                onComplete: performPopupLayoutAfterValidate
            });

            function performPopupLayoutAfterValidate():void {
                if (popupsVisible.indexOf(pd) == -1) {
                    // Popup was removed before shown
                    return;
                }

                // perform layout
                alignPopup(pd);
                alignCallout(pd);

                if (pd.keepPositionOnResize_) {
                    pd.instance_.addEventListener(ResizeEvent.RESIZE, function (event:ResizeEvent):void {
                        alignPopup(pd);
                        alignCallout(pd);
                    }, false, 0, true);
                }

                pd.instance_.addEventListener(CloseEvent.CLOSE, onPopupSelfClose);

                if (pd.hideAfter_) {
                    TweenLite.to(this, pd.hideAfter_, {
                        onComplete: function ():void { remove(pd); }
                    });
                }

                if (pd.hideByClickOutside_) {
                    pd.instance_.addEventListener(MouseEvent.MOUSE_DOWN, onPopupMouseDown, false, 0, true);
                }

                var instanceIndex:int = getElementIndex(pd.instance_);
                if (instanceIndex == numElements - 1 || containsElement(fogLayer) && instanceIndex < getElementIndex(fogLayer)) {
                    pd.instance_.visible = true;
                }

                if (pd.modal_) {
                    pd.instance_.setFocus();
                    pd.instance_.addEventListener(FocusEvent.FOCUS_OUT, onModalPopupFocusOut, false, 0, true);
                }

                pd.onPopupOpen_.dispatch(pd.instance_);
            }
        }


        private function onModalPopupFocusOut(e:FocusEvent):void {
            if (!e.relatedObject) {
                return;
            }

            var target:UIComponent = UIComponent(e.relatedObject);
            var popup:UIComponent = UIComponent(e.currentTarget);
            var obj:DisplayObjectContainer = target.parent;

            // check if focus was changed inside modal popup only
            while (obj && obj != popup) {
                obj = obj.parent;
            }

            if (!obj || obj != popup) {
                target.tabEnabled = target.focusEnabled = false;
                popup.setFocus();
            }
        }


        private function onPopupSelfClose(event:CloseEvent):void {
            remove(getPopupDescriptorFor(event.target));
        }


        /**
         * Find Popup Descriptor for a VISIBLE popup instance.
         * @param popupInstance
         * @return
         */
        private function getPopupDescriptorFor(popupInstance:*):PopupDescriptor {
            for each(var pd:PopupDescriptor in popupsVisible) {
                if (pd.instance_ == popupInstance) {
                    return pd;
                }
            }
            return null;
        }


        /**
         * Check what popup(s) were clicked and removes all that wasn't but
         * that has  hideByClickOutside_ == true.
         * Several popups can be clicked in case of theirs overlap.
         * @param event
         */
        private function onStageMouseDown(event:MouseEvent):void {
            for each (var pd:PopupDescriptor in popupsVisible) {
                if (pd.hideByClickOutside_ && !popupsClicked[pd.instance_]) {
                    remove(pd);
                }
            }
            popupsClicked = new Dictionary(true);
        }


        /**
         * To trace "mouse down outside" we use flash event bubbling effect
         * @param event
         */
        private function onPopupMouseDown(event:MouseEvent):void {
            popupsClicked[event.currentTarget] = true;
        }


        private function removePopupVisible(d:IPopupDescriptor):void {
            var pd:PopupDescriptor = d as PopupDescriptor;

            pd.instance_.removeEventListener(CloseEvent.CLOSE, onPopupSelfClose);
            pd.instance_.removeEventListener(MouseEvent.MOUSE_DOWN, onPopupMouseDown);
            pd.instance_.removeEventListener(FocusEvent.FOCUS_OUT, onModalPopupFocusOut);
            pd.instance_.removeEventListener(CloseEvent.CLOSE, onPopupSelfClose);

            popupsVisible.splice(popupsVisible.indexOf(pd), 1);
            dispatchEvent(new Event("popupsChange"));

            if (containsElement(pd.instance_)) {
                removeElement(pd.instance_);
            }

            if (pd.modal_) {
                modalPopupsVisible -= 1;
            }

            if (containsElement(fogLayer)) {
                if (!modalPopupsVisible || numElements == 1) {
                    removeElement(fogLayer);
                    if (focusedObjectBehind) {
                        focusedObjectBehind.setFocus();
                        focusedObjectBehind = null;
                    }
                }
                else {
                    // show the top modal dialog
                    var fogIndex:int = getElementIndex(fogLayer);
                    for (var i:int = fogIndex + 1; i < numElements; i++) {
                        var elem:IVisualElement = getElementAt(i);
                        if (i < numElements - 1) {
                            elem.visible = false;
                            elem.removeEventListener(FocusEvent.FOCUS_OUT, onModalPopupFocusOut);
                        }
                        else {
                            elem.visible = true;
                            elem.addEventListener(FocusEvent.FOCUS_OUT, onModalPopupFocusOut);
                        }
                    }
                }
            }

            pd.onPopupClose_.dispatch(pd.instance_);
            addEventListener(Event.ENTER_FRAME, processQueue);
        }


        /**
         * Trying to arrange popup as callout to some object
         * @param pd
         * @return true on success
         */
        private function alignCallout(pd:PopupDescriptor):Boolean {
            if (!pd.anchor) {
                return false;
            }
            return calloutArranger.arrange(pd);
        }


        private function alignPopup(pd:PopupDescriptor):void {
            if (pd.verticalAlign_ == VerticalAlign.BOTTOM) {
                pd.instance_.y = height - pd.marginBottom_ - pd.instance_.getLayoutBoundsHeight();
            }
            else if (pd.verticalAlign_ == VerticalAlign.TOP) {
                pd.instance_.y = pd.marginTop_;
            }
            else if (pd.verticalAlign_ == VerticalAlign.MIDDLE) {
                pd.instance_.y = (height - pd.instance_.getLayoutBoundsHeight()) / 2;
            }
            else if (pd.verticalAlign_ == VerticalAlign.JUSTIFY) {
                pd.instance_.y = 0;
                pd.instance_.height = pd.anchor ? pd.anchor.height : height;
            }


            if (pd.horizontalAlign_ == HorizontalAlign.LEFT) {
                pd.instance_.x = pd.marginLeft_;
            }
            else if (pd.horizontalAlign_ == HorizontalAlign.RIGHT) {
                pd.instance_.x = width - pd.marginRight_ - pd.instance_.getLayoutBoundsWidth();
            }
            else if (pd.horizontalAlign_ == HorizontalAlign.CENTER) {
                pd.instance_.x = (width - pd.instance_.getLayoutBoundsWidth()) / 2;
            }
            else if (pd.horizontalAlign_ == HorizontalAlign.JUSTIFY) {
                pd.instance_.x = 0;
                pd.instance_.width = pd.anchor ? pd.anchor.width : width;
            }
        }


        override public function setFocus():void {
            if (numElements == 0) {
                return;
            }
            var popup:UIComponent = getElementAt(numElements - 1) as UIComponent;
            if (popup) {
                popup.setFocus();
            }
        }
    }
}
