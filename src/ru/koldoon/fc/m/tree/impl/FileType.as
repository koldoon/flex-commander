package ru.koldoon.fc.m.tree.impl {
    public class FileType {
        public static const REGULAR:int = 0;
        public static const DIRECTORY:int = 1;
        public static const SYMBOLIC_LINK:int = 2;
        public static const SOCKET_LINK:int = 3;
        public static const FIFO:int = 4;
        public static const BLOCK_SPECIAL:int = 5;
        public static const CHARACTER_SPECIAL:int = 6;


        public static const FILE_TYPE_BY_ATTR:Object = {
            "b": BLOCK_SPECIAL,
            "c": CHARACTER_SPECIAL,
            "d": DIRECTORY,
            "l": SYMBOLIC_LINK,
            "s": SOCKET_LINK,
            "p": FIFO,
            "-": REGULAR
        }

    }
}
