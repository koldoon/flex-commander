package ru.koldoon.fc.conf {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    [Event(name="change", type="flash.events.Event")]

    public class ThemeManager extends EventDispatcher {
        public function ThemeManager() {
        }


//        [Embed(source="SampleTheme.json", mimeType="application/octet-stream")]
//        private static const SampleTheme:Class

        private static var _instance:ThemeManager;

        public static function getInstance():ThemeManager {
            if (!_instance) {
                _instance = new ThemeManager();
            }
            return _instance;
        }


        private var _theme:Theme;

        [Bindable(event="change")]
        public function get theme():Theme {
            return _theme;
        }


        public function setTheme(theme:Theme):void {
            _theme = theme;
            dispatchEvent(new Event(Event.CHANGE));
        }

    }
}
