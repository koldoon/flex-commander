package ru.koldoon.fc.m.popups {

    public interface ICalloutDescriptor extends IPopupDescriptor {

        /**
         * Set list of positions to try before defaults will be applyed.
         * @param priorities Array of CalloutPosition.
         */
        function position(priorities:Array):ICalloutDescriptor;
    }
}
