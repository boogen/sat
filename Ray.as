package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;

    public class Ray extends Sprite {

        private var speed:Number;

        public function Ray() {
            super();
            speed = 4 + Math.random() * 4;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void {
            graphics.lineStyle(2, 0xffbb00, 0.5);
            graphics.moveTo(0, -40);
            graphics.lineTo(0, 40);
            stage.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        private function enterFrame(e:Object):void {
            this.y -= speed;

            if (y <= -500) {
                y = 500;
            }
        }

   }
}