package ru.koldoon.fc.utils {
    public function trim(str:String):String {
        if (!str || str.length == 0) {
            return "";
        }

        while (str.length > 0 && str.charAt(0) == " ") {
            str = str.slice(1);
        }
        while (str.length > 0 && str.charAt(str.length - 1) == " ") {
            str = str.slice(0, str.length - 1);
        }

        return str;
    }
}
