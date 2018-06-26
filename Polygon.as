package {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.events.*;

    public class Polygon extends Draggable {
        private var _vertices:Vector.<Point>;
        private var dot:Sprite;
        private var mx:Number = 0;
        private var my:Number = 0;
        private var angle:Number = 0;
        public var color:int;
        private var prevAngle:Number = 0;

        public function Polygon(color:int, vertices:Vector.<Point>, fill:Boolean = true) {
            this.color = color;
            if (fill) {
                graphics.beginFill(color);
            }
            else {
                graphics.lineStyle(1, color);
            }
            graphics.moveTo(vertices[0].x, vertices[0].y);
            for (var i:int = 1; i < vertices.length; i++) {
                graphics.lineTo(vertices[i].x, vertices[i].y);
            }
            graphics.lineTo(vertices[0].x, vertices[0].y);
            graphics.endFill();
            this._vertices = vertices;

            var minX:Number =  1000000;
            var maxX:Number = -1000000;
            var minY:Number =  1000000;
            var maxY:Number = -1000000;

            for each (var p:Point in vertices) {
                if (p.x < minX) {
                    minX = p.x;
                }
                if (p.x > maxX) {
                    maxX = p.x;
                }
                if (p.y < minY) {
                    minY = p.y;
                }
                if (p.y > maxY) {
                    maxY = p.y;
                }
            }

            mx = (minX + maxX) / 2;
            my = (minY + maxY) / 2;

            maxX += 20;
            minX -= 20;
            maxY += 20;
            minY -= 20;

            var bb:Sprite = new Sprite();
            bb.graphics.beginFill(0xdddddd, 0);
            bb.graphics.drawRect(minX, minY, maxX - minX, maxY - minY);
            bb.graphics.endFill();
            addChild(bb);

            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);

            dot = new Sprite();
            dot.graphics.beginFill(0xff0000);
            dot.graphics.drawCircle(0, 0, 5);
            dot.graphics.endFill();
            dot.x = maxX;
            dot.y = 0 ;
            addChild(dot);
            dot.visible = false;

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void {

            dot.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);

        }

        private function onDrag(e:MouseEvent):void {
            enabled = false;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            removeEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);


            prevAngle = angle;

        }

        private function onDragStop(e:MouseEvent):void {
            enabled = true;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
        }

        private function onMouseMove(e:MouseEvent):void {
            var dx:Number = e.stageX - this.x - parent.x;
            var dy:Number = e.stageY - this.y - parent.y;
            angle += Math.atan2(dy, dx) - prevAngle;
            this.rotation = angle * 180 / Math.PI;
            prevAngle = angle;
            
        }

        public function get vertices():Vector.<Point> {
            var result:Vector.<Point> = new Vector.<Point>();
            for each (var p:Point in _vertices) {
                var np:Point = new Point();
                np.x = Math.cos(angle) * p.x - Math.sin(angle) * p.y;
                np.y = Math.sin(angle) * p.x + Math.cos(angle) * p.y;
                result.push(np);
            }

            return result;
        }

        private function onMouseOver(e:Object):void {
            dot.visible = true;
        }

        private function onMouseLeave(e:Object):void {
            dot.visible = false;
        }
    }
}
