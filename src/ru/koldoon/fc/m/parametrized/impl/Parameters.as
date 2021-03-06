package ru.koldoon.fc.m.parametrized.impl {
    import ru.koldoon.fc.m.parametrized.IParam;
    import ru.koldoon.fc.m.parametrized.IParameters;

    /**
     * Simple implementation of IParameters
     */
    public class Parameters implements IParameters {
        public function Parameters(list:Array = null) {
            setup(list);
        }


        /**
         * @inheritDoc
         */
        public function get list():Array {
            return _list;
        }


        /**
         * @inheritDoc
         */
        public function param(name:String):IParam {
            var p:IParam = _paramsIndex
                ? _paramsIndex[name] || new Param(name)
                : new Param(name);

            if (!_paramsIndex || !_paramsIndex[name]) {
                addParam(p);
            }
            return p;
        }


        /**
         * @inheritDoc
         */
        public function setup(params:Array):void {
            for each (var p:IParam in params) {
                if (_paramsIndex[p.name]) {
                    param(p.name).value = p.value;
                }
                else {
                    addParam(p);
                }
            }
        }


        public function addParam(p:IParam):Parameters {
            _list.push(p);
            _paramsIndex[p.name] = p;
            return this;
        }


        protected var _paramsIndex:Object = {};
        protected var _list:Array = [];
    }
}
