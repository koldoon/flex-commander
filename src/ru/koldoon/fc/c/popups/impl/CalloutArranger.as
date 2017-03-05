package ru.koldoon.fc.c.popups.impl {
    import flash.geom.Point;

    import ru.koldoon.fc.utils.notEmpty;

    import spark.components.CalloutPosition;
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

            verticalArranger[CalloutPosition.AFTER] = putVerAfter;
            verticalArranger[CalloutPosition.BEFORE] = putVerBefore;
            verticalArranger[CalloutPosition.END] = putVerEnd;
            verticalArranger[CalloutPosition.START] = putVerStart;
            verticalArranger[CalloutPosition.MIDDLE] = putVerMiddle;
        }


        public function arrange(pd:PopupDescriptor):Boolean {
            this.pd = pd;
            this.calloutWidth = pd.instance_.width;
            this.calloutHeight = pd.instance_.height;
            this.anchorWidth = pd.anchor.width;
            this.anchorHeight = pd.anchor.height;
            this.anchorOrigin = canvas.globalToLocal(pd.anchor.localToGlobal(new Point()));

            var va:Function = verticalArranger[pd.verticalPosition_];
            var ha:Function = horizontalArranger[pd.horizontalPosition_];

            if (va && ha) { // fully explicit
                va();
                ha();

                return true;
            }
            else if (va && !ha) {
                va();
                if ([CalloutPosition.BEFORE, CalloutPosition.AFTER].indexOf(pd.verticalPosition_) != -1) {
                    return putHorMiddle() || putHorStart() || putHorEnd() || putHorBefore() || putHorAfter();
                }
                else {
                    return putHorBefore() || putHorAfter();
                }
            }
            else if (!va && ha) {
                ha();
                if ([CalloutPosition.BEFORE, CalloutPosition.AFTER].indexOf(pd.horizontalPosition_) != -1) {
                    return putVerMiddle() || putVerStart() || putVerEnd() || putVerBefore() || putVerAfter();
                }
                else {
                    return putVerBefore() || putVerAfter();
                }
            }
            else if (!va && !ha) { // fully automatic
                if (putHorMiddle() || putHorStart() || putHorEnd()) {
                    return putVerBefore() || putVerAfter();
                }

                if (putVerMiddle() || putVerStart() || putVerEnd()) {
                    return putHorBefore() || putHorAfter();
                }
            }
            return false; // can not arrange
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


        private function putHorBefore():Boolean {
            return fitHorizontally(anchorOrigin.x - pd.marginRight_ - calloutWidth);
        }


        private function putHorStart():Boolean {
            return fitHorizontally(anchorOrigin.x);
        }


        private function putHorMiddle():Boolean {
            return fitHorizontally(anchorOrigin.x - (calloutWidth - anchorWidth) / 2);
        }


        private function putHorEnd():Boolean {
            return fitHorizontally(anchorOrigin.x + anchorWidth - calloutWidth);
        }


        private function putHorAfter():Boolean {
            return fitHorizontally(anchorOrigin.x + anchorWidth + pd.marginLeft_);
        }


        /**
         * Checks if callout with given X-coordinate is fully visible,
         * if so, change callout x.
         */
        private function fitHorizontally(x:Number):Boolean {
            var explicit:Boolean = notEmpty(pd.horizontalPosition_) && pd.horizontalPosition_ != CalloutPosition.AUTO;
            if ((x - pd.marginLeft_ < 0 || x + calloutWidth + pd.marginRight_ > canvas.width) && !explicit) {
                return false;
            }
            pd.instance_.x = x;

            if (pd.instance_.x - pd.marginLeft_ < 0) {
                pd.instance_.x = pd.marginLeft_;
            }

            if (pd.instance_.x + calloutWidth + pd.marginRight_ > canvas.width) {
                pd.instance_.x = canvas.width - pd.marginRight_ - calloutWidth;
            }
            return true;
        }


        private function putVerBefore():Boolean {
            return fitVertically(anchorOrigin.y - pd.marginBottom_ - calloutHeight);
        }


        private function putVerStart():Boolean {
            return fitVertically(anchorOrigin.y);
        }


        private function putVerMiddle():Boolean {
            return fitVertically(anchorOrigin.y - (calloutHeight - anchorHeight) / 2);
        }


        private function putVerEnd():Boolean {
            return fitVertically(anchorOrigin.y + anchorHeight - calloutHeight);
        }


        private function putVerAfter():Boolean {
            return fitVertically(anchorOrigin.y + anchorHeight + pd.marginTop_);
        }


        /**
         * Checks if callout with given Y-coordinate is fully visible,
         * if so, change callout y.
         */
        private function fitVertically(y:Number):Boolean {
            var explicit:Boolean = notEmpty(pd.verticalPosition_) && pd.verticalPosition_ != CalloutPosition.AUTO;
            if ((y - pd.marginTop_ < 0 || y + calloutHeight + pd.marginBottom_ > canvas.height) && !explicit) {
                return false;
            }
            pd.instance_.y = y;

            if (pd.instance_.y - pd.marginTop_ < 0) {
                pd.instance_.y = pd.marginTop_;
            }

            if (pd.instance_.y + calloutHeight + pd.marginBottom_ > canvas.height) {
                pd.instance_.y = canvas.height - pd.marginBottom_ - calloutHeight;
            }
            return true;
        }

    }
}
