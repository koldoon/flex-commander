package ru.koldoon.fc.m.app.impl.commands.mkdir {
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.m.app.IPanel;
    import ru.koldoon.fc.m.app.impl.BindingProperties;
    import ru.koldoon.fc.m.app.impl.commands.AbstractBindableCommand;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.parametrized.IParametrized;
    import ru.koldoon.fc.m.popups.IPopupDescriptor;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.INode;
    import ru.koldoon.fc.m.tree.ITreeEditor;
    import ru.koldoon.fc.m.tree.ITreeMkDirOperation;
    import ru.koldoon.fc.m.tree.ITreeProvider;
    import ru.koldoon.fc.m.tree.impl.FileNodeUtil;

    public class MakeDirectoryCommand extends AbstractBindableCommand {

        public static const NEW_DIR_NAME:String = "New Directory";


        public function MakeDirectoryCommand() {
            bindings = [
                new BindingProperties("F7")
            ];
        }


        override public function execute():void {
            panel = app.getActivePanel();
            dir = panel.directory;
            tp = dir.getTreeProvider();

            showInitDialog();
        }


        private function showInitDialog():void {
            var p:MakeDirectoryInitDialog = new MakeDirectoryInitDialog();
            var pd:IPopupDescriptor = app.popupManager.add().instance(p).modal(true);
            var te:ITreeEditor = tp as ITreeEditor;

            mkDirOperation = te.mkDir()
                .setParent(dir)
                .setName(NEW_DIR_NAME);

            p.dir = FileNodeUtil.getPath(dir);
            p.name = NEW_DIR_NAME;
            p.addEventListener(MouseEvent.CLICK, onPopupClick);
            p.addEventListener(KeyboardEvent.KEY_DOWN, onPopupKeyDown);

            if (mkDirOperation is IParametrized) {
                var parametrized:IParametrized = IParametrized(mkDirOperation);
                parametrized.getParameters().setup(context.parameters.list);
                p.parameters = parametrized.getParameters().list;
            }


            function onPopupClick(e:MouseEvent):void {
                if (p.cancelButton == e.target) { cancel() }
                else if (p.okButton == e.target) { ok() }
            }


            function onPopupKeyDown(e:KeyboardEvent):void {
                if (e.keyCode == Keyboard.ESCAPE) { cancel() }
                else if (e.keyCode == Keyboard.ENTER) { ok() }
            }


            function cancel():void {
                app.popupManager.remove(pd);
                mkDirOperation.cancel();
            }


            function ok():void {
                app.popupManager.remove(pd);
                mkDirOperation.setName(p.name);
                newDirName = p.name;
                beginCreate();
            }
        }


        private function beginCreate():void {
            mkDirOperation
                .status
                .onComplete(refreshPanels)
                .operation
                .execute();
        }


        private function refreshPanels(op:IAsyncOperation):void {
            panel.directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    panel.selection.reset();
                    panel.refresh();

                    // Navigate to created node
                    var dir:INode;
                    panel.directory.nodes.some(function (n:INode, i:int, arr:Array):Boolean {
                        if (n.name == newDirName) {
                            dir = n;
                            return true;
                        }
                        else {
                            return false;
                        }
                    });

                    if (dir) {
                        panel.selectedNode = dir;
                    }
                });

            // in case if both panels shows the same dir
            app.getPassivePanel().directory.refresh()
                .status
                .onComplete(function (op:IAsyncOperation):void {
                    app.getPassivePanel().refresh();
                });
        }


        private var panel:IPanel;
        private var dir:IDirectory;
        private var tp:ITreeProvider;
        private var newDirName:String;
        private var mkDirOperation:ITreeMkDirOperation;
    }
}
