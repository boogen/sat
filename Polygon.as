package {
    import flash.display.Sprite;
    import flash.geom.Point;

    public class Polygon extends Draggable {

        public var vertices:Vector.<Point>;

        public function Polygon(color:int, vertices:Vector.<Point>) {
            graphics.beginFill(color);
            graphics.moveTo(vertices[0].x, vertices[0].y);
            for (var i:int = 1; i < vertices.length; i++) {
                graphics.lineTo(vertices[i].x, vertices[i].y);
            }
            graphics.lineTo(vertices[0].x, vertices[0].y);
            graphics.endFill();
            this.vertices = vertices;
        }
    }
}
