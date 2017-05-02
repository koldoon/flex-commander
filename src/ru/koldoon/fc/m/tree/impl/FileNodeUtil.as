package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;
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
            var fsPath:Array = [];
            var nodesPath:Array = node.getPath();

            // example with link nodes in middle
            // "/users/koldoon/tmp/linktodir(/etc)/etc(private/etc)/etc/*.*"

            var pn:INode = null;

            for each (var n:INode in nodesPath) {
                if (pn is LinkNode) {
                    // squash link nodes.
                    // all next nodes will be the top link targets
                    fsPath.pop();
                }

                if (n is LinkNode) {
                    var ref:String = LinkNode(n).reference;
                    var parts:Array = ref.split("/");

                    if (parts[0] == "") {
                        fsPath = parts.slice(1);
                    }
                    else {
                        if (parts[0] == "..") {
                            parts.shift();
                            fsPath.pop();
                        }
                        else if (parts[0] == ".") {
                            parts.shift();
                        }
                        fsPath = fsPath.concat(parts);
                    }
                }
                else {
                    fsPath.push(n.name);
                }
                pn = n;
            }


            if (fsPath.length > 0 && fsPath[0] != "") {
                // Add root "/"
                fsPath.unshift("");
            }

            return fsPath.length >= 2 ? fsPath.join("/") : "/";
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
