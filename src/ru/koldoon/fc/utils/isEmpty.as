package ru.koldoon.fc.utils {
    public function isEmpty(obj:Object):Boolean {
        return obj == null || obj === "" || (obj.hasOwnProperty('length') && obj.length === 0);
    }
}
