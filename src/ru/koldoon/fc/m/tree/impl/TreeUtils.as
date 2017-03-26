package ru.koldoon.fc.m.tree.impl {
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.utils.notEmpty;

    public class TreeUtils {

        public static function getPathString(node:INode):String {
            var path:Array = node.getPath();
            var fsPath:Array = [];

            for each (var n:INode in path) {
                if (notEmpty(n.label)) {
                    fsPath.push(n.label);
                }
            }
            return "/" + fsPath.join("/");
        }

    }
}
