package ru.koldoon.fc.m.app.impl {
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import ru.koldoon.fc.m.parametrized.IParameters;
    import ru.koldoon.fc.m.parametrized.impl.Parameters;

    /**
     * This options will be checked on keys combination or node Enter press.
     */
    public class BindingProperties {

        public function BindingProperties(keysCombination:String = null, nodeValue:RegExp = null) {
            this.keysCombination = keysCombination;
            this.nodeValue = nodeValue;
            this.parameters = new Parameters();
        }


        /**
         * Params modifier. This is useful if you want to setup
         * keyboard binding to the same command but with specific
         * default params.
         * Since command params are taken from the underneath operation,
         * we don't know their count and names exactly, they depend on
         * concrete operation implementation, but anyway we can modify them
         * on assumption
         */
        public var parameters:IParameters;


        public function setParams(params:Array):BindingProperties {
            parameters.setup(params);
            return this;
        }


        /**
         * Keyboard combination as <code>getCombinationString()</code> returns
         */
        public var keysCombination:String;


        /**
         * Node Value Matching RegExp validator.
         * When user press Enter on a file,
         * application searches for a appropriate command to execute
         * in order they are installed in application getContext
         */
        public var nodeValue:RegExp;



        public static function optKeysDown(event:KeyboardEvent):Boolean {
            return event.altKey || event.commandKey || event.controlKey || event.shiftKey;
        }


        public static function detectCombination(event:KeyboardEvent):String {
            if (!OPT_KEYS_MAP[event.keyCode] && event.keyCode != Keyboard.TAB) {
                return getCombinationString(event);
            }
            else {
                return null;
            }
        }


        public static function getCombinationString(event:KeyboardEvent):String {
            var c:Array = [];
            if (event.controlKey) {
                c.push(OPT_KEYS_MAP[Keyboard.CONTROL]);
            }
            if (event.altKey) {
                c.push(OPT_KEYS_MAP[Keyboard.ALTERNATE]);
            }
            if (event.shiftKey) {
                c.push(OPT_KEYS_MAP[Keyboard.SHIFT]);
            }
            if (event.commandKey) {
                c.push(OPT_KEYS_MAP[Keyboard.COMMAND]);
            }

            if (!OPT_KEYS_MAP[event.keyCode]) {
                c.push(SPECIAL_KEYS_MAP[event.keyCode] || String.fromCharCode(event.charCode).toLocaleUpperCase());
            }

            return c.join("-");
        }


        public static const OPT_KEYS_MAP:Object = {};
        {
            OPT_KEYS_MAP[Keyboard.CONTROL] = "Ctrl";
            OPT_KEYS_MAP[Keyboard.ALTERNATE] = "Alt";
            OPT_KEYS_MAP[Keyboard.SHIFT] = "Shift";
            OPT_KEYS_MAP[Keyboard.COMMAND] = "Cmd";
        }


        public static const SPECIAL_KEYS_MAP:Object = {};
        {
            SPECIAL_KEYS_MAP[Keyboard.F1] = "F1";
            SPECIAL_KEYS_MAP[Keyboard.F2] = "F2";
            SPECIAL_KEYS_MAP[Keyboard.F3] = "F3";
            SPECIAL_KEYS_MAP[Keyboard.F4] = "F4";
            SPECIAL_KEYS_MAP[Keyboard.F5] = "F5";
            SPECIAL_KEYS_MAP[Keyboard.F6] = "F6";
            SPECIAL_KEYS_MAP[Keyboard.F7] = "F7";
            SPECIAL_KEYS_MAP[Keyboard.F8] = "F8";
            SPECIAL_KEYS_MAP[Keyboard.F9] = "F9";
            SPECIAL_KEYS_MAP[Keyboard.F10] = "F10";
            SPECIAL_KEYS_MAP[Keyboard.F11] = "F11";
            SPECIAL_KEYS_MAP[Keyboard.F12] = "F12";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_1] = "1";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_2] = "2";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_3] = "3";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_4] = "4";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_5] = "5";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_6] = "6";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_7] = "7";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_8] = "8";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_9] = "9";
            SPECIAL_KEYS_MAP[Keyboard.NUMBER_0] = "0";
            SPECIAL_KEYS_MAP[Keyboard.EQUAL] = "=";
            SPECIAL_KEYS_MAP[Keyboard.BACKSPACE] = "Bsp";
            SPECIAL_KEYS_MAP[Keyboard.SPACE] = "Space";
            SPECIAL_KEYS_MAP[Keyboard.ENTER] = "Enter";
            SPECIAL_KEYS_MAP[Keyboard.ESCAPE] = "Esc";
            SPECIAL_KEYS_MAP[Keyboard.TAB] = "Tab";
            SPECIAL_KEYS_MAP[Keyboard.LEFT] = "Left";
            SPECIAL_KEYS_MAP[Keyboard.RIGHT] = "Right";
            SPECIAL_KEYS_MAP[Keyboard.DOWN] = "Down";
            SPECIAL_KEYS_MAP[Keyboard.UP] = "Up";
        }

    }
}
