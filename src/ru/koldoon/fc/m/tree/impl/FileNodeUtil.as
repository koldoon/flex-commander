package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.utils.F;

    public class FileNodeUtil {

        /**
         * Format size in bytes in human readable way
         */
        public static function getFormattedSize(bytes:Number):String {
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


        /**
         * Get file system path for a FileNode. All symlinks in the
         * path are resolved except the target itself
         * @param node
         * @param resolveLinks "all" | "path" | "none"
         */
        public static function getFileSystemPath(node:INode, resolveLinks:String = "path"):String {
            var p:INode = node;
            var fsPath:Array = [];
            var head:Boolean = true;

            while (p && !(p is ITreeProvider)) {
                if (head && resolveLinks == "path" || resolveLinks == "none") {
                    fsPath.unshift(p.name);
                }
                else {
                    if (p is LinkNode && LinkNode(p).reference.charAt(0) == "/") {
                        // Root directory reference.
                        // Such a path is absolute, no further processing is needed
                        fsPath.unshift(LinkNode(p).reference.substr(1));
                        break;
                    }
                    else if (p is LinkNode) {
                        fsPath.unshift(LinkNode(p).reference);
                    }
                    else {
                        fsPath.unshift(p.name);
                    }
                }

                head = false;
                p = p.parent;
            }

            // Add root "/"
            fsPath.unshift("");

            return fsPath.length > 1 ? fsPath.join("/") : "/";
        }


        /**
         * Find a path of file as if it would be in another dirs
         * @param sourceDir source dir root
         * @param sourceFile file full path (from top root /) inside source dir
         * @param targetDir
         */
        public static function getTargetPath(sourceDir:String, sourceFile:String, targetDir:String):String {
            var buf:Array = ["/"];
            var diff:String = sourceFile.substr(sourceDir.length);

            if (targetDir.length > 0) {
                if (targetDir.charAt(0) == "/") {
                    buf.push(targetDir.substr(1));
                }
                else {
                    buf.push(targetDir);
                }
            }

            if (diff.length > 0) {
                buf.push("/");

                if (diff.charAt(0) == "/") {
                    buf.push(diff.substr(1));
                }
                else {
                    buf.push(diff);
                }
            }

            return buf.join("");
        }
    }
}
