package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Stage;
    import flash.geom.Point;
    import flash.text.TextField;

    [SWF(width="1024", height="768")]
    public class Main extends Sprite {

        private var sun:Sprite = new Sprite();
        private var plane:Sprite = new Sprite();
        private var polygons:Vector.<Polygon> = new Vector.<Polygon>();
        private var collisionTf:TextField = new TextField();
        private var rays:Sprite = new Sprite();
        private var rayArray:Vector.<Ray> = new Vector.<Ray>();

        public function Main() {
            createSun();
            sun.y = sun.x = 50;
            addChild(sun);
            graphics.lineStyle(1, 0xdddddd);
            graphics.drawEllipse(0, 50, stage.stageWidth, stage.stageHeight - 100);
            
            createRays();

            initShadowPlane(sun);
            collisionTf.text = "collision";
            collisionTf.textColor = 0xff0000;
            addChild(collisionTf);

            var vertices:Vector.<Point> = new <Point>[new Point(-100, -30), new Point(100, -30), new Point(100, 30), new Point(-100, 30)];

            //var polygon:Sprite = new Polygon(0x33ff55, vertices);
            var polygon:Sprite = new Polygon(0x33ff55, generateVertices(4, 100));
            polygons.push(polygon);
            polygon.x = stage.stageWidth/2 + 100;
            polygon.y = stage.stageHeight/2 + 50;
            addChild(polygon);
            //vertices = new <Point>[new Point(-75, 100), new Point(0, -50), new Point(75, 100)];
            polygon = new Polygon(0x3299bb, generateVertices(6, 120));
            polygon.x = stage.stageWidth/2 - 100;
            polygon.y = stage.stageHeight/2 - 50;
            polygons.push(polygon);
            addChild(polygon);
            stage.addEventListener(Event.ENTER_FRAME, adjustShadowPlane);
            stage.addEventListener(Event.ENTER_FRAME, castShadows);
            stage.addEventListener(Event.ENTER_FRAME, checkRays);
            sun.x = stage.stageWidth / 2;
        }

        private function createRays():void {
            rays.x = stage.stageWidth / 2;
            rays.y = stage.stageHeight / 2;

            for (var i:int = 0; i < 100; ++i) {
                var ray:Ray = new Ray();
                ray.x = (Math.random() - 0.5) * stage.stageWidth ;
                ray.y = (Math.random() - 0.5) * stage.stageHeight;
                rays.addChild(ray);

                addChild(rays);

                rayArray.push(ray);
            }
        }

        private function createSun():void {
            sun.graphics.beginFill(0xffbb00);
            sun.graphics.drawCircle(0, 0, 40);
            sun.graphics.endFill();

            sun.graphics.lineStyle(5, 0xffbb00);
            for (var i:int = 0; i < 12; ++i) {
                var angle:Number = i * 2 * Math.PI / 12;
                var r1:Number = 40;
                var r2:Number = 60;
                sun.graphics.moveTo( r1 * Math.cos(angle), r1 * Math.sin(angle));
                sun.graphics.lineTo( r2 * Math.cos(angle), r2 * Math.sin(angle));
            }

            sun.addEventListener(MouseEvent.MOUSE_DOWN, onSunDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, onSunDragStop);

        }

        private function onSunDrag(e:MouseEvent):void {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        private function onSunDragStop(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        private function onMouseMove(e:MouseEvent):void {
            var angle:Number = Math.atan2(e.stageY - stage.stageHeight / 2, e.stageX - stage.stageWidth / 2);
            sun.x = stage.stageWidth / 2 + Math.cos(angle) * stage.stageWidth / 2;
            sun.y = stage.stageHeight / 2 + Math.sin(angle) * (stage.stageHeight - 100) / 2;
        }


        private function initShadowPlane(sun:Sprite):void {
            plane.graphics.beginFill(0xcccccc);
            plane.graphics.moveTo(-800, 0);
            plane.graphics.lineTo(800, 0);
            plane.graphics.lineTo(800, -600);
            plane.graphics.lineTo(-800, -600);
            plane.graphics.lineTo(-800, 0);
            plane.graphics.endFill();
            addChild(plane);
        }

        private function checkRays(e:Event):void {
            for each (var ray:Ray in rayArray) {
                for each (var polygon:Polygon in polygons) {
                    ray.checkCollision(polygon);
                }
            }
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
                shadow.graphics.beginFill(0x333333, 0.5);
                shadow.graphics.lineStyle(0, 0x0, 0);
                shadow.graphics.moveTo(ks[0], 0);
                shadow.graphics.lineTo(ks[ks.length - 1], 0);
                shadow.graphics.lineTo(ks[ks.length - 1], -500);
                shadow.graphics.lineTo(ks[0], -500);
                shadow.graphics.lineTo(ks[0], 0);
                shadow.graphics.endFill();
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
            var angle:Number = (Math.atan2(dy, dx) + Math.PI /2) * 180 / Math.PI;
            plane.rotation = angle;
            rays.rotation = angle;
            plane.x = stage.stageWidth/2 + dx / 2;
            plane.y = stage.stageHeight/2 + dy / 2;
        }


        private function generateVertices(n:int, radius:Number):Vector.<Point> {
            var angle:Number = 2 * Math.PI / n;

            var result:Vector.<Point> = new Vector.<Point>();

            for (var i:int = 0; i < n; ++i) {
                var x:Number = Math.cos(i * angle) * radius;
                var y:Number = Math.sin(i * angle) * radius;
                
                var p:Point = new Point();
                p.x = x;
                p.y = y;
                result.push(p);
            }

            return result;
        }
    }
}
