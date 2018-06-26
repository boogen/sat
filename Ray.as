package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Point;

    public class Ray extends Sprite {

        private var speed:Number;

        private static var zero:Point = new Point(0, 0);

        public function Ray() {
            super();
            speed = 16 + Math.random() * 16;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void {
            graphics.lineStyle(2, 0xffbb00, 0.5);
            graphics.moveTo(0, -40);
            graphics.lineTo(0, 40);
            stage.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        public function checkCollision(polygon:Polygon):Boolean {
            var p:Point = localToGlobal(zero);
            p.x -= polygon.x;
            p.y -= polygon.y;
            var vertices:Vector.<Point> = polygon.vertices;
            for (var i:int = 0; i < vertices.length; ++i) {
                var next:int = (i + 1) % vertices.length;
                var v1:Point = vertices[next].subtract(vertices[i]);
                var v2:Point = p.subtract(vertices[i]);
                
                var cross:Number = v1.x * v2.y - v1.y * v2.x;
                if (cross < 0) {
                    return false;
                }
                
            }

            y = 500;
            return true;
        }

        private function enterFrame(e:Object):void {
            this.y -= speed;

            if (y <= -500) {
                y = 500;
            }
        }

   }
}