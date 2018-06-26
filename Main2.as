package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Stage;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.display.CapsStyle;

    [SWF(width="1024", height="768")]
    public class Main2 extends Sprite {

        private var pp:Sprite = new Sprite();
        private var plane:Sprite = new Sprite();
        private var polygons:Vector.<Polygon> = new Vector.<Polygon>();
        private var collisionTf:TextField = new TextField();
        private var rays:Sprite = new Sprite();
        private var rayArray:Vector.<Ray> = new Vector.<Ray>();

        public function Main2() {
            
            pp.x = stage.stageWidth / 2;
            pp.y = stage.stageHeight / 2;
            addChild(pp);
            var polygon:Sprite = new Polygon(0x33ff55, generateVertices(6, 130), false);
            polygons.push(polygon);
            polygon.x =  100;
            polygon.y =  50;
            pp.addChild(polygon);
            polygon = new Polygon(0x3299bb, generateVertices(4, 65), false);
            polygon.x = 100;
            polygon.y = 50;
            polygons.push(polygon);
            pp.addChild(polygon);

            shadowPlane();
            addChild(plane);

            stage.addEventListener(Event.ENTER_FRAME, shadowPlane);
        }



        private function shadowPlane(e:Event = null):void {

            plane.x = stage.stageWidth / 2;
            plane.y = stage.stageHeight / 2;

            plane.graphics.clear();

            var overlaps:Vector.<Overlap> = new Vector.<Overlap>();

           for each (var p:Polygon in polygons) {
               var vertices:Vector.<Point>  = p.vertices;
               for (var i:int = 0; i < vertices.length; ++i) {
                   var d:Point = new Point();
                   var i2:int = (i + 1) % vertices.length;
                   d.y = vertices[i2].x - vertices[i].x;
                   d.x = vertices[i2].y - vertices[i].y;
                   d.x = -d.x;

                   var m:Point = new Point();
                   m.x = -d.y * 2.5;
                   m.y = d.x * 2.5;

                   plane.graphics.lineStyle(2, 0xaaaaaa);
                   plane.graphics.moveTo(m.x - 10 * d.x , m.y - 10 * d.y );
                   plane.graphics.lineTo(m.x + d.x * 10 , m.y + d.y * 10);

                  

                   var ks:Vector.<Number> = new Vector.<Number>();
                   for each (var v:Point in p.vertices) {
                       var dx:Number = p.x + v.x - m.x;
                       var dy:Number = p.y + v.y - m.y;
                       ks.push( (dx * d.x + dy * d.y) / (d.x * d.x + d.y * d.y));
                   }
                   ks.sort(function(a:Number, b:Number):Number {
                        return a - b;
                    });
                   
                    plane.graphics.lineStyle(10, polygons[0].color, 0.5, false, "normal", CapsStyle.NONE);
                    plane.graphics.moveTo(m.x + ks[0] * d.x, m.y + ks[0] * d.y);
                    plane.graphics.lineTo(m.x + ks[ks.length - 1] * d.x, m.y + ks[ks.length - 1] * d.y);


                   var ks1:Vector.<Number> = new Vector.<Number>();
                   for each (var v:Point in polygons[1].vertices) {
                       dx = polygons[1].x + v.x - m.x;
                       dy = polygons[1].y + v.y - m.y;
                       ks1.push( (dx * d.x + dy * d.y) / (d.x * d.x + d.y * d.y));
                   }
                   ks1.sort(function(a:Number, b:Number):Number {
                        return a - b;
                    });
                   
                    plane.graphics.lineStyle(10, polygons[1].color, 0.5, false, "normal", CapsStyle.NONE);
                    plane.graphics.moveTo(m.x + ks1[0] * d.x, m.y + ks1[0] * d.y);
                    plane.graphics.lineTo(m.x + ks1[ks1.length - 1] * d.x, m.y + ks1[ks1.length - 1] * d.y);

                
                    var ov:Number = Math.max(0, Math.min(ks[ks.length - 1], ks1[ks1.length - 1]) - Math.max(ks[0], ks1[0]));
                    var op:Overlap = new Overlap();
                    op.x = d.x * ov;
                    op.y = d.y * ov;
                    op.overlap = ov;
                    overlaps.push(op);
               }


               overlaps.sort(function(a:Overlap, b:Overlap):Number {
                       return a.overlap - b.overlap;
                   });

               
               if (overlaps[0].overlap > 0) {
               plane.graphics.lineStyle(2, 0, 0.5);
               plane.graphics.moveTo(polygons[1].x, polygons[1].y);
               plane.graphics.lineTo(polygons[1].x + overlaps[0].x, polygons[1].y + overlaps[0].y);
           }
               break;
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
