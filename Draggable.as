package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;

    public class Draggable extends Sprite {
        private var dx:Number;
        private var dy:Number;
        protected var enabled:Boolean = true;

        public function Draggable() {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void {
            addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
        }

        private function onDrag(e:MouseEvent):void {
            dx = x - e.stageX;
            dy = y - e.stageY;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        private function onDragStop(e:MouseEvent):void {
            scaleX = scaleY = 1;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        private function onMouseMove(e:MouseEvent):void {
            if (enabled) {
                x = e.stageX + dx;
                y = e.stageY + dy;
            }
        }
    }
}