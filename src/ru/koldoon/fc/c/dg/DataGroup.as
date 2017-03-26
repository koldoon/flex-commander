package ru.koldoon.fc.c.dg {
    import mx.core.mx_internal;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;

    import spark.components.DataGroup;
    import spark.components.IItemRenderer;

    use namespace mx_internal;

    /**
     * Collection "On the Fly" Sorting optimized DataGroup.
     * Use in the corresponding List's skin.
     */
    public class DataGroup extends spark.components.DataGroup {

        /**
         * When Data group is used with spark List Component, after
         * collection refresh there is a logic to update current caret position,
         * which in its turn changes scroll position. We don't need to change scroll position
         * is this case, so to simplify fix we just prevent list from change scrolling
         * in the very next time.
         */
        private var preventScrollPositionChange:int = 0;


        override mx_internal function dataProvider_collectionChangeHandler(event:CollectionEvent):void {
            if (event.kind == CollectionEventKind.REFRESH) {

                // Just update renderers with new data from data provider.

                var len:int = numElements;
                for (var i:int = 0; i < len; i++) {
                    var r:IItemRenderer = getElementAt(i) as IItemRenderer;
                    if (r) {
                        updateRenderer(r, r.itemIndex, dataProvider.getItemAt(r.itemIndex));
                    }
                }

                preventScrollPositionChange = 1;

            }
            else {
                super.mx_internal::dataProvider_collectionChangeHandler(event);
            }
        }


        override public function set verticalScrollPosition(value:Number):void {
            if (preventScrollPositionChange) {
                preventScrollPositionChange--;
                return;
            }

            super.verticalScrollPosition = value;
        }

    }
}
