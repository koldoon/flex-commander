package ru.koldoon.fc.c.popups.impl {
    public class CalloutPosition {
        public function CalloutPosition(horizontal:String = AUTO, vertical:String = AUTO) {
            this.horizontal = horizontal;
            this.vertical = vertical;
        }


        [Inspectable(enumeration="before,start,middle,any,end,after")]
        public var vertical:String;

        [Inspectable(enumeration="before,start,middle,any,end,after")]
        public var horizontal:String;


        /**
         *  Position the trailing edge of the callout before the leading edge of the owner.
         */
        public static const BEFORE:String = "before";

        /**
         *  Position the leading edge of the callout at the leading edge of the owner.
         */
        public static const START:String = "start";

        /**
         *  Position the horizontalCenter of the callout to the horizontalCenter of the owner.
         */
        public static const MIDDLE:String = "middle";

        /**
         *  Position the horizontalCenter of the callout to the horizontalCenter of the owner
         *  but if callout is bigger by some side, it will be shifted to margin line
         */
        public static const ANY:String = "any";

        /**
         *  Position the trailing edge of the callout at the trailing edge of the owner.
         */
        public static const END:String = "end";

        /**
         *  Position the leading edge of the callout after the trailing edge of the owner.
         */
        public static const AFTER:String = "after";

        /**
         *  Position the callout on the exterior of the owner where the callout
         *  requires the least amount of resizing to fit.
         */
        public static const AUTO:String = "auto";

    }
}
