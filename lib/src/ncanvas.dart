part of umiuni2d_sprite_flutter;

class TinyFlutterNCanvas extends core.CanvasRoze {

  TinyFlutterNCanvas(this.canvas) {
    numOfCircleElm = 12;
  }

  Canvas canvas;

  double get contextWidht => 2.0;
  double get contextHeight => -2.0;

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
  void clearClip(core.Stage stage, {List<Object> cache: null}) {
    flush();
    canvas.restore();
    canvas.save();
  }

  @override
  void clipRect(core.Stage stage, core.Rect rect, {Matrix4 m:null}) {
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
    canvas.save();
  }

  @override
  void drawVertexRaw(List<double> svertex, List<int> index) {
    int w = 0;
    int h = 0;
    if(this.flImg != null) {
      w = this.flImg.w;
      h = this.flImg.h;
    }
    Vertices v = new Vertices.roze(svertex, this.flTex, index, w, h);
    drawVertices(v);
  }

  void drawVertices(core.Vertices vertices) {
    Paint p = new Paint()..style = sky.PaintingStyle.fill;
    p.color = new sky.Color.fromARGB(0xff,0xff, 0xff, 0xff);

    TinyFlutterImage curImage = (this.flImg as TinyFlutterImage);

    if (curImage != null && curImage.rawImage.image != null) {
      sky.TileMode tmx = sky.TileMode.clamp;
      sky.TileMode tmy = sky.TileMode.clamp;
      data.Float64List matrix4 = new Matrix4.identity().storage;
      sky.ImageShader imgShader = new sky.ImageShader(curImage.rawImage.image , tmx, tmy, matrix4);
      p.shader = imgShader;
    }
    //p.blendMode = sky.BlendMode.src;// ^ sky.BlendMode.multiply;
    if((vertices as Vertices).raw != null) {
      canvas.drawVertices((vertices as Vertices).raw, sky.BlendMode.srcIn, p);
    }
//    canvas.drawVertices((vertices as Vertices).raw2, sky.BlendMode.multiply, p);

  }

  @override
  void updateMatrix() {
    //canvas.setMatrix(this.getMatrix().storage);
  }
}


class Vertices extends core.Vertices {
  sky.Vertices raw;

  //
//  Vertices(
//      VertexMode mode,
//      data.Float32List positions, {
//        data.Float32List textureCoordinates,
//        data.Int32List colors,
//        data.Int32List indices,
//      }) {
//      //
//      // dart:ui is wrong now(2018/2/19).
//      //   if (colors != null && colors.length * 2 != positions.length)
//      //   throw new ArgumentError('"positions" and "colors" lengths must match.');
//      //
//      raw = new sky.Vertices.raw(toSkyVertexMode(mode),
//          positions,
//          textureCoordinates: textureCoordinates,
//          colors: colors,
//          indices:indices);
//  }


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
          textureSrc[i] = new Offset(cCoordinates[2 * i + 0]*w, cCoordinates[2 * i + 1]*h);
          if(cCoordinates[2 * i + 0] != 0.0 || cCoordinates[2 * i + 1] != 0.0) {
            isZero = false;
          };
        }
      }

      if(textureSrc == null || isZero == true) {
        print("VV");
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
      List<double> positions, {
        List<double> cCoordinates,
        List<int> colors,
        List<int> indices,
      }) :super.list(mode, positions, cCoordinates:cCoordinates, colors:colors, indices:indices){
    List<Offset> positionsSrc = new List(positions.length~/2);
    List<Color> colorsSrc = new List(positionsSrc.length);
    List<Offset> textureSrc = null;
    if(cCoordinates != null){
      textureSrc = new List(cCoordinates.length~/2);
    }


    for(int i=0;i< positionsSrc.length;i++) {
      positionsSrc[i] = new Offset(positions[2*i+0], positions[2*i+1]);
      colorsSrc[i] = new Color.fromARGB(colors[4*i+0], colors[4*i+1], colors[4*i+2], colors[4*i+3]);
    }
    if(textureSrc != null) {
      for (int i = 0; i < textureSrc.length; i++) {
        textureSrc[i] = new Offset(cCoordinates[2 * i + 0], cCoordinates[2 * i + 1]);
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
