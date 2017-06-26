package ru.koldoon.fc.m.tree.impl.fs.cl.utils {
    import ru.koldoon.fc.m.interactive.impl.AccessDeniedMessage;
    import ru.koldoon.fc.m.interactive.impl.Interaction;

    public class LFS_CLO_Lines {
        /**
         * Common permission denied regexp.
         * - Group 1: operation name
         * - Group 2: target path
         */
        public static const PERMISSION_DENIED:RegExp = /^(\w+):\s+(.*):\s+Permission denied$/;


        /**
         * Creates interaction message for each access denied error line in a list
         */
        public static function checkAccessDeniedLines(lines:Array, interaction:Interaction):Boolean {
            var exists:Boolean = false;
            for each (var l:String in lines) {
                var pd:Object = PERMISSION_DENIED.exec(l);
                if (pd) {
                    exists = true;
                    interaction.setMessage(new AccessDeniedMessage(pd[2]));
                }
            }
            return true;
        }

    }
}
