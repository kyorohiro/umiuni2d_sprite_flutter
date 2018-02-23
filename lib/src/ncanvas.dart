part of umiuni2d_sprite_flutter;

class TinyFlutterNCanvas extends core.Canvas {

  Canvas canvas;

  TinyFlutterNCanvas(this.canvas):super(2.0, -2.0);

  Paint toPaintWithRawFlutter(core.Paint p) {
    Paint pp = new Paint();
    pp.color = new Color(p.color.value);
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

  @override
  void clipRect(core.Rect rect, {Matrix4 m:null}) {
    flush();
    if(m == null) {
       m = getMatrix();
    }
    Vector3 v1 = new Vector3(rect.x, rect.y, 0.0);
    Vector3 v2 = new Vector3(rect.x, rect.y + rect.h, 0.0);
    Vector3 v3 = new Vector3(rect.x + rect.w, rect.y + rect.h, 0.0);
    Vector3 v4 = new Vector3(rect.x + rect.w, rect.y, 0.0);
    v1 = m * v1;
    v2 = m * v2;
    v3 = m * v3;
    v4 = m * v4;
    Path path = new Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v4.x, v4.y);
    canvas.clipPath(path);
  }

  @override
  clear() {
    super.clear();
    canvas.save();
  }

  void drawVertexWithColor(List<double> positions, List<double> colors, List<int> indices,{bool hasZ:false}) {
    Vertices v = new Vertices.list(core.VertexMode.triangles, positions, 0,0,colors: colors, indices:indices);
    if((v as Vertices).raw != null) {
      Paint p = new Paint()..style = sky.PaintingStyle.fill;
      p.color = new sky.Color.fromARGB(0xff,0xff, 0xff, 0xff);
      canvas.drawVertices((v as Vertices).raw, sky.BlendMode.srcIn, p);
    }
  }

  void drawVertexWithImage(List<double> positions, List<double> cCoordinates, List<int> indices, core.Image img,
      {List<double> colors, bool hasZ:false}) {
    TinyFlutterImage curImage = (img as TinyFlutterImage);

    Vertices v = new Vertices.list(
        core.VertexMode.triangles,
        positions,
        img.w,img.h,
        cCoordinates:cCoordinates,
        colors: colors,
        indices:indices,);
    sky.Paint p = new sky.Paint()..style = sky.PaintingStyle.fill;

    if((v as Vertices).raw != null) {
      if (curImage != null && curImage.rawImage.image != null) {
        sky.TileMode tmx = sky.TileMode.clamp;
        sky.TileMode tmy = sky.TileMode.clamp;
        data.Float64List matrix4 = new Matrix4.identity().storage;
        sky.ImageShader imgShader = new sky.ImageShader(curImage.rawImage.image , tmx, tmy, matrix4);
        p.shader = imgShader;
      }
      p.color = new sky.Color.fromARGB(0xff,0xff, 0xff, 0xff);
      canvas.drawVertices((v as Vertices).raw, sky.BlendMode.srcIn, p);
    }
  }

}


class Vertices extends core.Vertices {
  sky.Vertices raw;

  Vertices.roze(List<double> vertces, List<double> cCoordinates, List<int> indices, int w, int h) :super.list(core.VertexMode.triangles, null){
      int n = vertces.length~/8;
      List<Offset> positionsSrc = new List(n);
      List<Color> colorsSrc = new List(n);
      List<Offset> textureSrc =  null;//new List(n);

      for(int i=0;i<n;i++) {
        positionsSrc[i] = new Offset(vertces[8*i+0], vertces[8*i+1]);//3,4,1
        colorsSrc[i] = new Color.fromARGB(
            (255*vertces[8*i+6]).toInt(),
            (255*vertces[8*i+3]).toInt(),
            (255*vertces[8*i+4]).toInt(),
            (255*vertces[8*i+5]).toInt()
            );
      }
      if(cCoordinates != null && cCoordinates.length > 0){
        textureSrc = new List(positionsSrc.length);
      }

      bool isZero = true;
      if(textureSrc != null) {
        for (int i = 0; i < textureSrc.length; i++) {
          textureSrc[i] =
          new Offset(cCoordinates[2 * i + 0] * w, cCoordinates[2 * i + 1] * h);
          if (cCoordinates[2 * i + 0] != 0.0 ||
              cCoordinates[2 * i + 1] != 0.0) {
            isZero = false;
          };
        }
      }
      if(textureSrc == null || isZero == true) {

        raw = new sky.Vertices(
            toSkyVertexMode(core.VertexMode.triangles), positionsSrc,
            colors: colorsSrc,
            indices: indices);
      } else {
        raw = new sky.Vertices(
            toSkyVertexMode(core.VertexMode.triangles), positionsSrc,
            textureCoordinates: textureSrc,
            colors: colorsSrc,
            indices: indices);
      }
    }

  Vertices.list(
      core.VertexMode mode,
      List<double> positions, int w, int h, {
        List<double> cCoordinates,
        List<double> colors,
        List<int> indices,
      }) :super.list(mode, positions, cCoordinates:cCoordinates, colors:null, indices:indices){
    List<Offset> positionsSrc = new List(positions.length~/2);
    List<Color> colorsSrc = new List(positionsSrc.length);
    List<Offset> textureSrc = null;
    if(cCoordinates != null){
      textureSrc = new List(cCoordinates.length~/2);
    }


    for(int i=0;i< positionsSrc.length;i++) {
      positionsSrc[i] = new Offset(positions[2*i+0], positions[2*i+1]);
      colorsSrc[i] = new Color.fromARGB(
          (255*colors[4*i+0]).toInt(),
          (255*colors[4*i+1]).toInt(),
          (255*colors[4*i+2]).toInt(),
          (255*colors[4*i+3]).toInt());
    }
    if(textureSrc != null) {
      for (int i = 0; i < textureSrc.length; i++) {
        textureSrc[i] = new Offset(w*cCoordinates[2 * i + 0], h*cCoordinates[2 * i + 1]);
      }
    }
    raw = new sky.Vertices(toSkyVertexMode(mode), positionsSrc,
        textureCoordinates: textureSrc,
        colors: colorsSrc,
        indices:indices);
  }
  sky.VertexMode toSkyVertexMode(core.VertexMode mode) {
    switch(mode){
      case core.VertexMode.triangles:
        return sky.VertexMode.triangles;
      case core.VertexMode.triangleFan:
        return sky.VertexMode.triangleFan;
      case core.VertexMode.triangleStrip:
        return sky.VertexMode.triangleStrip;
    }
    return sky.VertexMode.triangles;
  }
}
