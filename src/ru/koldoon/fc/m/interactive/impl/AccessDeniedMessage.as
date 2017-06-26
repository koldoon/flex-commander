package ru.koldoon.fc.m.interactive.impl {
    public class AccessDeniedMessage extends Message {
        public function AccessDeniedMessage(path:String) {
            setData(path);
            setText("Permission Denied: " + path);
        }

    }
}
