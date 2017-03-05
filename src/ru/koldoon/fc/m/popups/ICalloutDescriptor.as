package ru.koldoon.fc.m.popups {
    import spark.components.CalloutPosition;

    public interface ICalloutDescriptor extends IPopupDescriptor {

        function verticalPosition(p:String = CalloutPosition.AUTO):ICalloutDescriptor

        function horizontalPosition(p:String = CalloutPosition.AUTO):ICalloutDescriptor

    }
}
