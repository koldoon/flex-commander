package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.utils.notEmpty;

    public class TreeUtils {

        public static function getPathString(node:INode):String {
            if (!node) {
                return "";
            }

            var path:Array = node.getPath();
            var fsPath:Array = [];

            for each (var n:INode in path) {
                if (notEmpty(n.name)) {
                    fsPath.push(n.name);
                }
            }
            return "/" + fsPath.join("/");
        }

    }
}
