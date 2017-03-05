package ru.koldoon.fc.c.material {
    import com.greensock.TweenMax;

    import flash.display.DisplayObject;
    import flash.display.Sprite;

    [Internal]
    [ExcludeClass]
    public class InkModel {
        public static var INK_START_ALPHA:Number = 0.4;
        public static var INK_START_SIZE:Number = 20;
        public static var ANIMATION_DURATION:Number = 0.4;

        public var inkX:Number = 0;
        public var inkY:Number = 0;
        public var inkSize:Number = 0;
        public var inkAlpha:Number = 0;

        private var canvas:Sprite;
        private var container:DisplayObject;


        public function stop():void {
            if (canvas) {
                canvas.graphics.clear();
            }
            if (container) {
                container.visible = false;
            }
            TweenMax.killTweensOf(this);
        }


        private function drawInk():void {
            canvas.graphics.clear();
            canvas.graphics.beginFill(0x0, inkAlpha);
            canvas.graphics.drawCircle(inkX, inkY, inkSize);
            canvas.graphics.endFill();
        }


        public function animate(canvas:Sprite, container:DisplayObject, onComplete:Function = null):void {
            stop();

            this.container = container;
            this.canvas = canvas;
            inkSize = INK_START_SIZE;
            inkAlpha = INK_START_ALPHA;
            container.visible = true;

            var d1:Number = Math.sqrt(inkX * inkX + inkY * inkY);
            var d2:Number = Math.sqrt(inkX * inkX + (canvas.height - inkY) * (canvas.height - inkY));
            var d3:Number = Math.sqrt((canvas.width - inkX) * (canvas.width - inkX) + inkY * inkY);
            var d4:Number = Math.sqrt((canvas.width - inkX) * (canvas.width - inkX) + (canvas.height - inkY) * (canvas.height - inkY));
            var size:Number = Math.max(d1, d2, d3, d4) * 1.2; // 20% bigger

            TweenMax.to(this, ANIMATION_DURATION, {
                inkSize:    size,
                inkAlpha:   0.05,
                onUpdate:   drawInk,
                onComplete: function ():void {
                    canvas = null;
                    container.visible = false;
                    if (onComplete != null) {
                        onComplete();
                    }
                }
            });
        }
    }
}
