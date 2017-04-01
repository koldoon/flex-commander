package ru.koldoon.fc.m.tree.impl.fs {
    import flash.debugger.enterDebugger;

    import ru.koldoon.fc.utils.F;

    public class FileNodeUtil {
        public static function getFormattedSize(bytes:Number):String {
            if (bytes < 0)
                enterDebugger();

            if (bytes > 1024 * 1024 * 1024 * 1024) {
                return F.getInstance().number1.format(bytes / 1024 / 1024 / 1024 / 1024) + "T";
            }
            else if (bytes > 1024 * 1024 * 1024) {
                return F.getInstance().number1.format(bytes / 1024 / 1024 / 1024) + "G";
            }
            else if (bytes > 1024 * 1024) {
                return F.getInstance().number1.format(bytes / 1024 / 1024) + "M";
            }
            else if (bytes > 1024) {
                return F.getInstance().number1.format(bytes / 1024) + "K";
            }
            else {
                return F.getInstance().number1.format(bytes);
            }
        }
    }
}
