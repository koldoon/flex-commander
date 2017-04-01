package ru.koldoon.fc.m.tree.impl.fs.copy {
    import ru.koldoon.fc.m.app.impl.commands.copy.CopyCommand;
    import ru.koldoon.fc.m.async.IAsyncCollection;
    import ru.koldoon.fc.m.async.IAsyncOperation;
    import ru.koldoon.fc.m.async.impl.Interaction;
    import ru.koldoon.fc.m.async.impl.InteractionMessage;
    import ru.koldoon.fc.m.async.impl.InteractionOption;
    import ru.koldoon.fc.m.async.impl.Param;
    import ru.koldoon.fc.m.async.impl.Parameters;
    import ru.koldoon.fc.m.async.interactive.IInteraction;
    import ru.koldoon.fc.m.async.interactive.IInteractiveOperation;
    import ru.koldoon.fc.m.async.parametrized.IParameters;
    import ru.koldoon.fc.m.async.parametrized.IParametrized;
    import ru.koldoon.fc.m.tree.IDirectory;
    import ru.koldoon.fc.m.tree.IFilesProvider;
    import ru.koldoon.fc.m.tree.ITreeSelector;
    import ru.koldoon.fc.m.tree.impl.FileSystemReference;
    import ru.koldoon.fc.m.tree.impl.fs.*;
    import ru.koldoon.fc.m.tree.impl.fs.console.LocalFileSystemCopyCommandLineOperation;
    import ru.koldoon.fc.m.tree.impl.fs.console.LocalFileSystemMkDirCommandLineOperation;
    import ru.koldoon.fc.utils.notEmpty;

    public class LocalFileSystemCopyOperation extends AbstractNodesBunchOperation implements IInteractiveOperation, IParametrized {
        public static const OVERWRITE_ALL:String = "OVERWRITE_ALL";
        public static const SKIP_ALL:String = "SKIP_ALL";


        public function LocalFileSystemCopyOperation() {
            parameters.setList([
                new Param(CopyCommand.OVERWRITE_ALL_EXISTING, false),
                new Param(CopyCommand.SKIP_ALL_EXISTING, false),
                new Param(CopyCommand.PRESERVE_ATTRIBUTES, true),
                new Param(CopyCommand.FOLLOW_LINKS, false)
            ]);

            interaction.onMessage(onInteractionMessage);
        }


        public function treeSelector(s:ITreeSelector):LocalFileSystemCopyOperation {
            selector = s;
            return this;
        }


        public function getParameters():IParameters {
            return parameters;
        }


        public function getInteraction():IInteraction {
            return interaction;
        }


        public function destination(d:IDirectory):LocalFileSystemCopyOperation {
            dstDir = d;
            filesProvider = d.getTreeProvider() as IFilesProvider;
            return this;
        }


        public function source(d:IDirectory):LocalFileSystemCopyOperation {
            srcDir = d;
            return this;
        }


        override protected function begin():void {
            filesProvider
                .getFiles([srcDir, dstDir])
                .onReady(function (ac:IAsyncCollection):void {
                    sourcePath = ac.items[0];
                    destinationPath = ac.items[1];
                    onPreparingComplete();
                });

            selector
                .execute()
                .getStatus()
                .onComplete(function (op:ITreeSelector):void {
                    if (notEmpty(op.nodes)) {
                        _nodes = op.nodes;
                        // Scan for files references in the list of INode recursively.
                        filesProvider
                            .getFiles(op.nodes)
                            .onReady(onFilesReferencesReady);
                    }
                    else {
                        // nothing to copy :(
                        done();
                    }
                })
                .onFault(function (data:Object):void { fault() });
        }


        // -----------------------------------------------------------------------------------
        // Impl
        // -----------------------------------------------------------------------------------

        private var selector:ITreeSelector;
        private var srcDir:IDirectory;
        private var dstDir:IDirectory;
        private var filesProvider:IFilesProvider;

        private var sourcePath:String;
        private var destinationPath:String;
        private var filesReferences:Array;
        private var parameters:Parameters = new Parameters();
        private var interaction:Interaction = new Interaction();


        private function onFilesReferencesReady(ac:IAsyncCollection):void {
            filesReferences = ac.items;
            onPreparingComplete();
        }


        private function onPreparingComplete():void {
            if (sourcePath && destinationPath && filesReferences) {
                _nodesProcessed = 0;
                copyNextFile();
            }
        }


        /**
         * Add Extra options to interaction message before it will be
         * caught by another code
         */
        private function onInteractionMessage(i:Interaction):void {
            var msg:InteractionMessage = i.getMessage() as InteractionMessage;
            msg.options.push(new InteractionOption("n", "Skip All", SKIP_ALL));
            msg.options.push(new InteractionOption("y", "Overwrite All", OVERWRITE_ALL));
            msg.onResponse(onInteractionResponse);
        }


        /**
         * Check extra options and modify startup params
         * @param option
         */
        private function onInteractionResponse(option:InteractionOption):void {
            if (option.context == OVERWRITE_ALL) {
                parameters.param(CopyCommand.OVERWRITE_ALL_EXISTING).value = true;
            }
            else if (option.context == SKIP_ALL) {
                parameters.param(CopyCommand.SKIP_ALL_EXISTING).value = true;
            }
        }


        // -----------------------------------------------------------------------------------
        // Copy CMD
        // -----------------------------------------------------------------------------------

        private var cmdLineOperation:IAsyncOperation;


        private function copyNextFile():void {
            if (cmdLineOperation || status.isCanceled) {
                return;
            }

            if (!nodes || nodesProcessed == nodes.length) {
                done();
            }
            else {
                var fsRef:FileSystemReference = filesReferences[nodesProcessed];

                if (fsRef.node is IDirectory) {
                    cmdLineOperation = new LocalFileSystemMkDirCommandLineOperation()
                        .path(getFileTargetPath(fsRef.path))
                        .execute();

                    cmdLineOperation
                        .getStatus()
                        .onFinish(continueCopy);
                }
                else {
                    cmdLineOperation = new LocalFileSystemCopyCommandLineOperation()
                        .sourceFilePath(fsRef.path)
                        .targetFilePath(getFileTargetPath(fsRef.path))
                        .preserveAttrs(parameters.param(CopyCommand.PRESERVE_ATTRIBUTES).value)
                        .overwriteExisting(parameters.param(CopyCommand.OVERWRITE_ALL_EXISTING).value)
                        .skipExisting(parameters.param(CopyCommand.SKIP_ALL_EXISTING).value)
                        .followSymlinks(parameters.param(CopyCommand.FOLLOW_LINKS).value)
                        .execute();

                    cmdLineOperation
                        .getStatus()
                        .onComplete(continueCopy)
                        .onFault(function (op:IAsyncOperation):void { fault() });

                    // Traverse remote interaction to ours
                    interaction.listenTo(IInteractiveOperation(cmdLineOperation).getInteraction())
                }
            }
        }


        private function continueCopy(op:IAsyncOperation):void {
            progress.setPercent(nodesProcessed / nodes.length * 100, this);
            cmdLineOperation = null;
            _nodesProcessed += 1;
            copyNextFile();
        }


        override public function cancel():void {
            if (selector) {
                selector.cancel();
            }

            if (cmdLineOperation) {
                cmdLineOperation.cancel();
            }

            super.cancel();
        }


        private function getFileTargetPath(sourceFilePath:String):String {
            return destinationPath + sourceFilePath.substr(sourcePath.length);
        }


    }
}
