package ru.koldoon.fc.conf {
    import flash.filesystem.File;

    import org.osflash.vanilla.update;

    import ru.koldoon.fc.m.storage.impl.sync.FS;

    public class AppConfig {
        private var f:File;
        private static var _instance:AppConfig;


        public function AppConfig() {
            f = File.userDirectory.resolvePath(".flexnavigator/settings.json");
            update(this, JSON.parse(FS.getInstance().readString(f) || "{}"));
        }


        public function save():void {
            FS.getInstance().writeString(f, JSON.stringify(this, null, 4));
        }


        public static function getInstance():AppConfig {
            if (!_instance) {
                _instance = new AppConfig();
            }
            return _instance;
        }


        // -----------------------------------------------------------------------------------
        // Stored Settings
        // -----------------------------------------------------------------------------------

        public var left_panel_path:String;
        public var right_panel_path:String;

    }
}
