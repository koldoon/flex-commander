package ru.koldoon.fc.conf {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    [Event(name="change", type="flash.events.Event")]

    public class ThemeManager extends EventDispatcher {
        public function ThemeManager() {
        }


        [Embed(source="SampleTheme.json", mimeType="application/octet-stream")]
        private static const SampleTheme:Class;
        private static var Instance:ThemeManager;

        public static function getInstance():ThemeManager {
            if (!Instance) {
                Instance = new ThemeManager();
            }
            return Instance;
        }

        private var _theme:ThemeVO;

        [Bindable(event="change")]
        public function get theme():ThemeVO {
            return _theme;
        }

        public function applyTheme(theme:ThemeVO):void {
            _theme = theme;
            dispatchEvent(new Event(Event.CHANGE));
        }

        public function resetTheme():void {
            _theme = null;
            dispatchEvent(new Event(Event.CHANGE));
        }

    }
}
