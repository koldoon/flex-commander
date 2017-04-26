package ru.koldoon.fc.c.popups.impl {
    import flash.geom.Point;

    import spark.components.Group;

    /**
     * Arranges Callout popup position relatively to given anchor visual element
     */
    public class CalloutArranger {
        public function CalloutArranger(canvas:Group) {
            this.canvas = canvas;

            horizontalArranger[CalloutPosition.AFTER] = putHorAfter;
            horizontalArranger[CalloutPosition.BEFORE] = putHorBefore;
            horizontalArranger[CalloutPosition.END] = putHorEnd;
            horizontalArranger[CalloutPosition.START] = putHorStart;
            horizontalArranger[CalloutPosition.MIDDLE] = putHorMiddle;
            horizontalArranger[CalloutPosition.ANY] = putHorAny;

            verticalArranger[CalloutPosition.AFTER] = putVerAfter;
            verticalArranger[CalloutPosition.BEFORE] = putVerBefore;
            verticalArranger[CalloutPosition.END] = putVerEnd;
            verticalArranger[CalloutPosition.START] = putVerStart;
            verticalArranger[CalloutPosition.MIDDLE] = putVerMiddle;
            verticalArranger[CalloutPosition.ANY] = putVerAny;

            defaultPositions = [
                new CalloutPosition(CalloutPosition.BEFORE, CalloutPosition.MIDDLE),
                new CalloutPosition(CalloutPosition.AFTER, CalloutPosition.MIDDLE),
                new CalloutPosition(CalloutPosition.BEFORE, CalloutPosition.START),
                new CalloutPosition(CalloutPosition.AFTER, CalloutPosition.START),
                new CalloutPosition(CalloutPosition.BEFORE, CalloutPosition.END),
                new CalloutPosition(CalloutPosition.AFTER, CalloutPosition.END),

                new CalloutPosition(CalloutPosition.MIDDLE, CalloutPosition.BEFORE),
                new CalloutPosition(CalloutPosition.MIDDLE, CalloutPosition.AFTER),
                new CalloutPosition(CalloutPosition.START, CalloutPosition.BEFORE),
                new CalloutPosition(CalloutPosition.START, CalloutPosition.AFTER),
                new CalloutPosition(CalloutPosition.END, CalloutPosition.BEFORE),
                new CalloutPosition(CalloutPosition.END, CalloutPosition.AFTER),

                new CalloutPosition(CalloutPosition.BEFORE, CalloutPosition.ANY),
                new CalloutPosition(CalloutPosition.AFTER, CalloutPosition.ANY),

                new CalloutPosition(CalloutPosition.ANY, CalloutPosition.BEFORE),
                new CalloutPosition(CalloutPosition.ANY, CalloutPosition.AFTER)
            ];
        }


        public function arrange(pd:PopupDescriptor):Boolean {
            this.pd = pd;
            this.calloutWidth = pd.instance_.getLayoutBoundsWidth();
            this.calloutHeight = pd.instance_.getLayoutBoundsHeight();
            this.anchorWidth = pd.anchor.width;
            this.anchorHeight = pd.anchor.height;
            this.anchorOrigin = canvas.globalToLocal(pd.anchor.localToGlobal(new Point()));

            var cp:CalloutPosition;
            var va:Function;
            var ha:Function;

            for each (cp in pd.position_) {
                va = verticalArranger[cp.vertical];
                ha = horizontalArranger[cp.horizontal];
                if (va() && ha()) {
                    return true;
                }
            }

            // if there is no custom position setup or it fails, try defaults
            for each (cp in defaultPositions) {
                va = verticalArranger[cp.vertical];
                ha = horizontalArranger[cp.horizontal];
                if (va() && ha()) {
                    return true;
                }
            }

            return false;
        }


        private var anchorOrigin:Point;
        private var anchorWidth:Number;
        private var anchorHeight:Number;
        private var calloutWidth:Number;
        private var calloutHeight:Number;
        private var canvas:Group;
        private var pd:PopupDescriptor;
        private var horizontalArranger:Object = {};
        private var verticalArranger:Object = {};
        private var defaultPositions:Array;


        private function putHorBefore():Boolean {
            return fitHorizontally(anchorOrigin.x - pd.marginRight_ - calloutWidth);
        }


        private function putHorStart():Boolean {
            return fitHorizontally(anchorOrigin.x);
        }


        private function putHorEnd():Boolean {
            return fitHorizontally(anchorOrigin.x + anchorWidth - calloutWidth);
        }


        private function putHorAfter():Boolean {
            return fitHorizontally(anchorOrigin.x + anchorWidth + pd.marginLeft_);
        }


        private function putHorMiddle():Boolean {
            return fitHorizontally(anchorOrigin.x - (calloutWidth - anchorWidth) / 2);
        }


        private function putHorAny():Boolean {
            var x:Number = anchorOrigin.x - (calloutWidth - anchorWidth) / 2;
            if (x - pd.marginLeft_ < 0) {
                x = pd.marginLeft_;
            }
            else if (x + calloutWidth + pd.marginRight_ > canvas.width) {
                x = canvas.width - pd.marginRight_ - calloutWidth;
            }
            return fitHorizontally(x);
        }


        /**
         * Checks if callout with given X-coordinate is fully visible,
         * if so, change callout x.
         */
        private function fitHorizontally(x:Number):Boolean {
            if (x - pd.marginLeft_ < 0 || x + calloutWidth + pd.marginRight_ > canvas.width) {
                return false;
            }
            pd.instance_.x = x;
            return true;
        }


        private function putVerBefore():Boolean {
            return fitVertically(anchorOrigin.y - pd.marginBottom_ - calloutHeight);
        }


        private function putVerStart():Boolean {
            return fitVertically(anchorOrigin.y);
        }


        private function putVerEnd():Boolean {
            return fitVertically(anchorOrigin.y + anchorHeight - calloutHeight);
        }


        private function putVerAfter():Boolean {
            return fitVertically(anchorOrigin.y + anchorHeight + pd.marginTop_);
        }


        private function putVerMiddle():Boolean {
            return fitVertically(anchorOrigin.y - (calloutHeight - anchorHeight) / 2);
        }


        private function putVerAny():Boolean {
            var y:Number = anchorOrigin.y - (calloutHeight - anchorHeight) / 2;
            if (y - pd.marginTop_ < 0) {
                y = pd.marginTop_;
            }
            else if (y + calloutHeight + pd.marginBottom_ > canvas.height) {
                y = canvas.height - pd.marginTop_ - calloutHeight;
            }
            return fitVertically(y);
        }


        /**
         * Checks if callout with given Y-coordinate is fully visible,
         * if so, change callout y.
         */
        private function fitVertically(y:Number):Boolean {
            if (y - pd.marginTop_ < 0 || y + calloutHeight + pd.marginBottom_ > canvas.height) {
                return false;
            }
            pd.instance_.y = y;
            return true;
        }

    }
}
