package ru.koldoon.fc.m.app.impl.commands.env {
    import ru.koldoon.fc.conf.AppConfig;
    import ru.koldoon.fc.m.app.impl.commands.AbstractCommand;

    public class ShutdownCommand extends AbstractCommand {

        override public function shutdown():void {
            AppConfig.getInstance().left_panel_path = app.leftPanel.directory.getPathString();
            AppConfig.getInstance().right_panel_path = app.rightPanel.directory.getPathString();
            AppConfig.getInstance().save();
        }
    }
}
