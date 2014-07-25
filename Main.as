package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Stage;
    import flash.geom.Point;
    import flash.text.TextField;

    [SWF(width="1024", height="768")]
    public class Main extends Sprite {

        private var sun:Sprite = new Draggable();
        private var plane:Sprite = new Sprite();
        private var polygons:Vector.<Polygon> = new Vector.<Polygon>();
        private var collisionTf:TextField = new TextField();

        public function Main() {
            sun.graphics.beginFill(0xff9900);
            sun.graphics.drawCircle(0, 0, 20);
            sun.graphics.endFill();
            sun.y = sun.x = 50;
            addChild(sun);
            initShadowPlane(sun);
            collisionTf.text = "collision";
            collisionTf.textColor = 0xff0000;
            addChild(collisionTf);

            var vertices:Vector.<Point> = new <Point>[new Point(-50, -25), new Point(50, -25), new Point(50, 25), new Point(-50, 25)];

            var polygon:Sprite = new Polygon(0x424242, vertices);
            polygons.push(polygon);
            polygon.x = stage.stageWidth/2;
            polygon.y = stage.stageHeight/2 + 50;
            addChild(polygon);
            vertices = new <Point>[new Point(0, -120), new Point(30, 25), new Point(-5, 25)];
            polygon = new Polygon(0x3299bb, vertices);
            polygon.x = stage.stageWidth/2;
            polygon.y = stage.stageHeight/2 - 50;
            polygons.push(polygon);
            addChild(polygon);
            stage.addEventListener(Event.ENTER_FRAME, adjustShadowPlane);
            stage.addEventListener(Event.ENTER_FRAME, castShadows);
            sun.x = stage.stageWidth / 2;
        }

        private function initShadowPlane(sun:Sprite):void {
            plane.graphics.lineStyle(3, 0xcccccc);
            plane.graphics.moveTo(-600, 0);
            plane.graphics.lineTo(600, 0);
            addChild(plane);
        }

        private function castShadows(e:Event):void {
            var cos:Number = Math.cos(plane.rotation * Math.PI / 180);
            var sin:Number = Math.sin(plane.rotation * Math.PI / 180);
            plane.removeChildren();
            var shadows:Vector.<Point> = new <Point>[];
            for each (var polygon:Polygon in polygons) {
                var ks:Vector.<Number> = new Vector.<Number>();
                for each (var v:Point in polygon.vertices) {
                    var dx:Number = polygon.x + v.x - plane.x;
                    var dy:Number = polygon.y + v.y - plane.y;
                    ks.push(dx * cos + dy * sin);
                }
                ks.sort(function(a:Number, b:Number):Number {
                        return a - b;
                    });
                var shadow:Sprite = new Sprite();
                shadow.graphics.lineStyle(1, 0x0);
                shadow.graphics.moveTo(ks[0], 0);
                shadow.graphics.lineTo(ks[ks.length - 1], 0);
                shadows.push(new Point(ks[0],ks[ks.length - 1])); 
                plane.addChild(shadow);
            }
            if ((shadows[0].x - shadows[1].y) * (shadows[0].y - shadows[1].x) < 0) {
                collisionTf.visible = true;
            }
            else {
                collisionTf.visible = false;
            }
        }
        private function adjustShadowPlane(e:Event):void {
            var dx:Number = stage.stageWidth/2 - sun.x;
            var dy:Number = stage.stageHeight/2 - sun.y;
            plane.rotation = (Math.atan2(dy, dx) + Math.PI /2) * 180 / Math.PI;
            plane.x = stage.stageWidth/2 + dx;
            plane.y = stage.stageHeight/2 + dy;
        }
    }
}
