package ru.koldoon.fc.c.text {
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import mx.controls.TextInput;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    import mx.formatters.IFormatter;

    import spark.components.supportClasses.SkinnableComponent;
    import spark.core.IDisplayText;

    use namespace mx_internal;

    [Event(name="valueCommit", type="mx.events.FlexEvent")]
    [Event(name="change", type="flash.events.Event")]

    [SkinState("normal")]
    [SkinState("focused")]
    [SkinState("disabled")]

    [Style(name="icon", type="Object")]
    [Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
    [Style(name="paddingRight", type="Number", format="Length", inherit="no")]

    /**
     * Skinnable text input optimized for mobile usage.
     */
    public class SkinnableTextInput extends SkinnableComponent {
        public function SkinnableTextInput() {
            // disable built-in validation handling for "errorString" property
            setStyle("showErrorSkin", false);
            setStyle("showErrorTip", false);

            addEventListener(MouseEvent.CLICK, clickHandler);
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
        }

        [SkinPart(required="true")]
        public var textInput:TextInput;

        [SkinPart(required="false")]
        public var promptLabel:IDisplayText;

        [SkinPart(required="false")]
        public var tipLabel:IDisplayText;

        // -----------------------------------------------------------------------------------
        // Public Interface
        // -----------------------------------------------------------------------------------

        private var _text:String;
        private var _prompt:String;
        private var _restrict:String;
        private var _displayAsPassword:Boolean = false;
        private var _editable:Boolean = true;
        private var _maxChars:int = 0;
        private var _formatter:IFormatter;


        /**
         * Don't allow to change the text
         */
        [Bindable]
        public function get editable():Boolean {
            return _editable;
        }

        public function set editable(value:Boolean):void {
            _editable = value;
            if (textInput) {
                textInput.editable = value;
                textInput.selectable = value;
            }
        }


        /**
         * Prompt text. Displayed over the text input if it's empty.
         */
        [Bindable]
        public function get prompt():String {
            return _prompt;
        }

        public function set prompt(value:String):void {
            _prompt = value;
            if (promptLabel) {
                promptLabel.text = value;
            }
        }


        /**
         * Text entered and displayed
         */
        [Bindable(event="change")]
        [Bindable(event="valueCommit")]
        public function get text():String {
            return _text;
        }

        public function set text(value:String):void {
            if (value == _text) {
                return;
            }

            _text = _formatter ? _formatter.format(value) : value;
            _selectAll = false;
            if (textInput) {
                textInput.text = _text;
                if (_text) {
                    textInput.setSelection(_text.length, _text.length);
                }
            }
            dispatchEvent(new Event(Event.CHANGE));
        }


        /**
         * Regexp of chars that allowed to enter
         */
        [Bindable]
        public function get restrict():String {
            return _restrict;
        }

        public function set restrict(value:String):void {
            _restrict = value;
            if (textInput) {
                textInput.restrict = value;
            }
        }


        /**
         * Hide chars entered
         */
        [Bindable]
        public function get displayAsPassword():Boolean {
            return _displayAsPassword;
        }

        public function set displayAsPassword(value:Boolean):void {
            _displayAsPassword = value;
            if (textInput) {
                textInput.displayAsPassword = value;
            }
        }


        /**
         * Maximum chars allowed to enter
         */
        [Bindable]
        public function get maxChars():int {
            return _maxChars;
        }

        public function set maxChars(value:int):void {
            _maxChars = value;
            if (textInput) {
                textInput.maxChars = value;
            }
        }


        /**
         * Apply formatter for the text entered
         */
        [Bindable]
        public function get formatter():IFormatter {
            return _formatter;
        }

        public function set formatter(value:IFormatter):void {
            _formatter = value;

            if (_formatter) {
                var formattedText:String = _formatter.format(_text);
                if (formattedText == _text) {
                    return;
                }

                if (textInput) {
                    textInput.text = _text;
                }
                dispatchEvent(new Event(Event.CHANGE));
            }
        }

        public function selectAll():void {
            if (textInput && textInput.text) {
                textInput.setSelection(0, textInput.text.length);
            }
            else if (_text) {
                _selectAll = true;
            }
        }

        // -----------------------------------------------------------------------------------
        // Internal
        // -----------------------------------------------------------------------------------

        private var _isFocused:Boolean;
        private var _changed:Boolean;
        private var _selectAll:Boolean;

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            if (instance == textInput) {
                textInput.text = _text;
                textInput.displayAsPassword = _displayAsPassword;
                textInput.needsSoftKeyboard = true;
                textInput.editable = _editable;
                textInput.selectable = _editable;
                textInput.restrict = _restrict;
                textInput.maxChars = _maxChars;
                textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
                textInput.addEventListener(FlexEvent.ENTER, textInput_enterHandler);
                textInput.addEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler);
                textInput.addEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler);

                if (_isFocused) {
                    setFocus();
                }

                if (_selectAll) {
                    textInput.setSelection(0, textInput.text.length);
                    _selectAll = false;
                }
            }

            if (instance == promptLabel) {
                promptLabel.text = _prompt;
            }
        }


        override protected function partRemoved(partName:String, instance:Object):void {
            super.partRemoved(partName, instance);

            if (instance == textInput) {
                textInput.removeEventListener(Event.CHANGE, textInput_changeHandler);
                textInput.removeEventListener(FlexEvent.ENTER, textInput_enterHandler);
                textInput.removeEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler);
                textInput.removeEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler);
            }
        }


        private function textInput_changeHandler(event:Event):void {
            if (_formatter) {
                var enteredText:String = textInput.text || "";
                var formattedText:String = _formatter.format(textInput.text) || "";
                var cursor:int = textInput.selectionActivePosition;

                if (textInput.text != formattedText) {
                    textInput.text = formattedText;
                    textInput.setSelection(cursor, cursor);
                }
                // move cursor to the end if formatting is unpredictable
                if (formattedText.substr(0, cursor).toUpperCase() != enteredText.substr(0, cursor).toUpperCase()) {
                    textInput.setSelection(formattedText.length, formattedText.length);
                }
            }

            if (_text != textInput.text) {
                _text = textInput.text;
                _changed = true;
                dispatchEvent(new Event(Event.CHANGE));
            }
        }

        private function textInput_focusInHandler(event:FocusEvent):void {
            _isFocused = true;
            if (textInput) {
                textInput.setSelection(textInput.text.length, textInput.text.length);
            }
            invalidateSkinState();
        }

        private function textInput_focusOutHandler(event:FocusEvent):void {
            _isFocused = false;
            if (_changed) {
                _changed = false;
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            if (textInput) {
                textInput.horizontalScrollPosition = 0;
            }
            invalidateSkinState();
        }

        private function textInput_enterHandler(event:FlexEvent):void {
            if (_isFocused) {
                stage.focus = null;
            }
        }

        override public function setFocus():void {
            _isFocused = true;
            invalidateSkinState();

            if (textInput && editable) {
                // Calling later so the skin/state can finish setting up before
                // accepting focus on textDisplay.
                callLater(textInput.setFocus);
            }
        }

        override protected function getCurrentSkinState():String {
            if (!enabled) {
                return "disabled";
            }
            else if (_isFocused) {
                return "focused";
            }
            else {
                return "normal";
            }
        }

        override public function get baselinePosition():Number {
            if (!validateBaselinePosition()) {
                return NaN;
            }
            else {
                return textInput ? (textInput.baselinePosition + textInput.y) : super.baselinePosition;
            }
        }


        // -----------------------------------------------------------------------------------
        // Focus management: remove focus by tap outside
        // -----------------------------------------------------------------------------------

        private var _isClicked:Boolean;

        private function addedToStageHandler(event:Event):void {
            stage.addEventListener(MouseEvent.CLICK, stage_clickHandler);
        }

        private function removedFromStageHandler(event:Event):void {
            stage.removeEventListener(MouseEvent.CLICK, stage_clickHandler);

            if (_isFocused) {
                stage.focus = null;
            }
        }

        private function stage_clickHandler(event:MouseEvent):void {
            if (_isClicked) {
                _isClicked = false;
            }
            else if (_isFocused) {
                stage.focus = null;
            }
        }

        private function clickHandler(event:MouseEvent):void {
            _isClicked = true;
        }
    }
}
