package ru.koldoon.fc.m.async.impl {
    import ru.koldoon.fc.m.async.parametrized.IParam;
    import ru.koldoon.fc.m.async.parametrized.IParameters;

    /**
     * Simple implementation of IParameters
     */
    public class Parameters implements IParameters {
        public function Parameters(list:Array = null) {
            setList(list);
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
            var p:IParam = _paramsIndex ? _paramsIndex[name] || new Param(name) : new Param(name);
            if (!_paramsIndex || !_paramsIndex[name]) {
                addParam(p);
            }
            return p;
        }


        /**
         * Overwrite existing params list with given.
         * @param l
         */
        public function setList(l:Array):void {
            _paramsIndex = _list = null;
            for each (var p:IParam in l) {
                addParam(p);
            }
        }


        public function addParam(p:IParam):Parameters {
            if (!_list) {
                _list = [];
            }

            if (!_paramsIndex) {
                _paramsIndex = {};
            }

            _list.push(p);
            _paramsIndex[p.name] = p;

            return this;
        }


        protected var _paramsIndex:Object;
        protected var _list:Array;
    }
}
