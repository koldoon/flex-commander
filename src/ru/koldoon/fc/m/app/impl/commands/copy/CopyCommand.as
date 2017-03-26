package ru.koldoon.fc.m.app.impl.commands.copy {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import org.spicefactory.lib.reflect.ClassInfo;

    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.*;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.AbstractNode;
    import ru.koldoon.fc.m.tree.impl.TreeUtils;
    import ru.koldoon.fc.m.tree.impl.fs.AbstractNodesBunchOperation;

    public class CopyCommand extends AbstractBindableCommand {
        public function CopyCommand() {
            super();
            bindingProperties_ = [
                new BindingProperties("F5")
            ];
        }


        override public function isExecutable(target:String):Boolean {
            var sp:IPanel = app.leftPanel == app.getTargetPanel(target) ? app.leftPanel : app.rightPanel;
            var srcNodes:Array = sp.selection.length > 0 ? sp.selection.getSelectedNodes() : [sp.selectedNode];

            if (srcNodes.length == 1 && (!srcNodes[0] || srcNodes[0] == AbstractNode.PARENT_NODE)) {
                // special node can not be processed
                return false;
            }

            return true;
        }


        override public function execute(target:String):void {
            var sp:IPanel = app.leftPanel.selectedNodeIndex != -1 ? app.leftPanel : app.rightPanel;
            var tp:IPanel = (sp == app.leftPanel) ? app.rightPanel : app.leftPanel; // opposite panel
            srcNodes = sp.selection.length > 0 ? sp.selection.getSelectedNodes() : [sp.selectedNode];
            srcDir = sp.directory;
            targetDir = tp.directory;
            srcTP = sp.directory.getTreeProvider();
            targetTP = tp.directory.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:CopyStartDialog = new CopyStartDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.nodesCount = srcNodes.length;
            p.targetDir = TreeUtils.getPathString(targetDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            setSourceNodeName();


            function setSourceNodeName():void {
                if (srcNodes.length == 1) {
                    p.nodeName = p.followSymlinks ? INode(srcNodes[0]).value : INode(srcNodes[0]).label;
                }
                else {
                    p.nodeName = null;
                }
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    app.popupManager.remove(pd);
                }
                else if (p.followSymlinksCheckBox == e.target) {
                    setSourceNodeName();
                }
                else if (p.okButton == e.target) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    app.popupManager.remove(pd);
                }
                else if (e.keyCode == Keyboard.ENTER) {
                    app.popupManager.remove(pd);
                    beginCopy();
                }
            }
        }


        private function beginCopy():void {
            if (ClassInfo.forInstance(srcTP).name == ClassInfo.forInstance(targetTP).name && srcTP is ITreeEditor) {
                var te:ITreeEditor = srcTP as ITreeEditor;
                showProgressDialog(te.copy(srcDir, targetDir, srcNodes));
            }
            else {
                // legacy operation through IFilesProvider
            }

        }


        private function showProgressDialog(op:IAsyncOperation):void {
            var p:CopyProgressDialog = new CopyProgressDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);

            p.nodesTotal = srcNodes.length;
            p.targetDir = TreeUtils.getPathString(targetDir);
            p.srcDir = TreeUtils.getPathString(srcDir);
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            var nbop:AbstractNodesBunchOperation = op as AbstractNodesBunchOperation;
            if (nbop) {
                nbop.progress.onProgress(function (op:AbstractNodesBunchOperation):void {
                    p.nodesTotal = op.nodesTotal;
                    p.currentNode = TreeUtils.getPathString(op.currentNode);
                    p.nodesProcessed = op.nodesProcessed;
                });
            }

            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) {
                    app.popupManager.remove(pd);
                }

                else if (p.backgroundButton == e.target) {
                }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) {
                    // ask for stop
                }
            }

        }


        private var srcTP:ITreeProvider;
        private var targetTP:ITreeProvider;
        private var srcDir:IDirectory;
        private var srcNodes:Array;
        private var targetDir:IDirectory;
    }
}
