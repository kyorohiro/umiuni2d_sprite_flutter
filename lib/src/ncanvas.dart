part of umiuni2d_sprite_flutter;

class TinyFlutterNCanvas extends core.Canvas {

  flu.Canvas canvas;

  TinyFlutterNCanvas(this.canvas):super(2.0, -2.0, true);

  flu.Paint toPaintWithRawFlutter(core.Paint p) {
    flu.Paint pp = new flu.Paint();
    pp.color = new flu.Color(p.color.value);
    pp.strokeWidth = p.strokeWidth;
    switch (p.style) {
      case core.PaintStyle.fill:
        pp.style = sky.PaintingStyle.fill;
        break;
      case core.PaintStyle.stroke:
        pp.style = sky.PaintingStyle.stroke;
        break;
    }
    return pp;
  }


  @override
  void clearClip({List<Object> cache: null}) {
    flush();
    canvas.restore();
    canvas.save();
  }

  void clipVertex(core.Vertices vertices) {
    List<double> positions = (vertices as Vertices)._positions;
    List<int> indices  = (vertices as Vertices)._indices;
    flush();
    if(positions.length <= 1) {
      return;
    }

    int length = indices.length;
    flu.Path path = new flu.Path();
    for(int i=0;i<length;i++) {
      int index = indices[i];
      if(0==i % 3) {
        path.moveTo(positions[2 * index + 0], positions[2 * index + 1]);
      } else {
        path.lineTo(positions[2 * index + 0], positions[2 * index + 1]);
      }
    }
    canvas.clipPath(path);

  }

  @override
  clear() {
    super.clear();
    canvas.save();
  }

  core.ImageShader createImageShader(core.Image image) {
    return new ImageShader(image);
  }

  core.Vertices createVertices(List<double> positions, List<double> colors, List<int> indices, {List<double> cCoordinates}) {
    return new Vertices.list(positions, indices, colors:colors, cCoordinates: cCoordinates);
  }


  void drawVertexWithColor(core.Vertices vertices, {bool hasZ:false}) {
    if((vertices as Vertices).raw != null) {
      print("draw color");
      flu.Paint p = new flu.Paint()..style = sky.PaintingStyle.fill;
      p.color = new sky.Color.fromARGB(0xff,0xff, 0xff, 0xff);
      canvas.drawVertices((vertices as Vertices).raw, sky.BlendMode.color, p);
    }
  }

  void drawVertexWithImage(core.Vertices vertices, core.ImageShader imgShader,
      {List<double> colors, bool hasZ:false}) {


    sky.Paint p = new sky.Paint()..style = sky.PaintingStyle.fill;

    if((vertices as Vertices).raw != null) {
      p.shader = (imgShader as ImageShader).raw;
      p.color = new sky.Color.fromARGB(0xff,0xff, 0xff, 0xff);
      canvas.drawVertices((vertices as Vertices).raw, sky.BlendMode.srcIn, p);
    }
  }

}


class Vertices extends core.Vertices {
  sky.Vertices raw;
  List<double> _positions;
  List<int> _indices;

  Vertices.list(
      List<double> positions, List<int> indices,
      { List<double> colors, List<double> cCoordinates}){
    List<flu.Offset> positionsSrc = new List(positions.length~/2);
    //
    //
    _positions = positions.toList(growable: false);
    _indices = indices.toList(growable: false);


    List<flu.Color> colorsSrc = (colors == null?null:new List(positionsSrc.length));
    List<flu.Offset> textureSrc = null;
    if(cCoordinates != null){
      textureSrc = new List(cCoordinates.length~/2);
    }


    for(int i=0;i< positionsSrc.length;i++) {
      positionsSrc[i] = new flu.Offset(positions[2*i+0], positions[2*i+1]);
    }

    if(colorsSrc != null) {
      for (int i = 0; i < positionsSrc.length; i++) {
        colorsSrc[i] = new flu.Color.fromARGB(
            (255 * colors[4 * i + 3]).toInt(),
            (255 * colors[4 * i + 0]).toInt(),
            (255 * colors[4 * i + 1]).toInt(),
            (255 * colors[4 * i + 2]).toInt());
      }
    }

    if(textureSrc != null) {
      for (int i = 0; i < textureSrc.length; i++) {
        textureSrc[i] = new flu.Offset(cCoordinates[2 * i + 0], cCoordinates[2 * i + 1]);
      }
    }
    raw = new sky.Vertices(sky.VertexMode.triangles, positionsSrc,
        textureCoordinates: textureSrc,
        colors: colorsSrc,
        indices:indices);
  }
}


class ImageShader extends core.ImageShader {
  sky.ImageShader _imgShader;
  sky.ImageShader get raw => _imgShader;
  int _w;
  int _h;
  int get w => _w;
  int get h => _h;
  ImageShader(core.Image rawImage) {
    sky.TileMode tmx = sky.TileMode.clamp;
    sky.TileMode tmy = sky.TileMode.clamp;
    data.Float64List matrix4 = new Matrix4.identity().storage;
    TinyFlutterImage curImage = (rawImage as TinyFlutterImage);
    _w = curImage.w;
    _h = curImage.h;
    _imgShader = new sky.ImageShader(curImage.rawImage.image , tmx, tmy, matrix4);
  }

  void dispose() {
    _imgShader = null;
  }
}