library umiuni2d_sprite_flutter;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as sky;
import 'dart:async';
import 'dart:math'as math;
import 'dart:io';
import 'dart:typed_data' as data;
import 'package:vector_math/vector_math_64.dart';
import 'package:umiuni2d_sprite/umiuni2d_sprite.dart' as core;

//
//
part 'src/stage.dart';
part 'src/ncanvas.dart';
part 'src/loader.dart';
//
//

class GameWidget extends SingleChildRenderObjectWidget implements core.GameWidget {
  core.Stage _stage;
  core.Stage get stage => _stage;

  core.OnStart onStart = null;
  core.OnLoop onLoop = null;


  GameWidget({
    core.DisplayObject root,
    double width:400.0,
    double height:300.0,
    this.assetsRoot: "web/"}) {
    if(root == null) {
      root = new core.GameRoot(width, height);
    }
    this._stage = this.createStage(root: root);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return (stage as TinyFlutterStage);
  }

  bool _isRun = false;
  void run() {
    if(_isRun == false) {
      runApp(this);
      _isRun = true;
    }
  }

  Future<GameWidget> start({core.OnStart onStart,core.OnLoop onLoop, bool useAnimationLoop:false}) async  {
    this.onStart = onStart;
    this.onLoop = onLoop;
    run();
    if(useAnimationLoop) {
      stage.start();
    }
    if(onStart != null) {
      onStart(this);
    }
    return this;
  }

  Future<GameWidget> stop() async {
    stage.stop();
    return this;
  }


  //
  //
  String assetsRoot;
  String get assetsPath => (assetsRoot.endsWith("/") ? assetsRoot : ""+assetsRoot+"/");

  bool tickInPerFrame = true;
  bool useTestCanvas = true; //false;
  bool useDrawVertexForPrimtive = true;

  @override
  core.Stage createStage({core.DisplayObject root}) {
    if(root == null) {
      root = new core.DisplayObject();
    }
    return new TinyFlutterStage(this, root);
  }

  @override
  Future<core.Image> loadImage(String path) async {
    return new TinyFlutterImage(await ResourceLoader.loadImage(""+assetsRoot+path));
  }

  @override
  Future<data.Uint8List> loadBytes(String path) async {
    return await ResourceLoader.loadBytes(""+assetsRoot+path);
  }

  @override
  Future<String> loadString(String path) async {
    String a = await ResourceLoader.loadString(""+assetsRoot+path);
    return a;
  }

  @override
  Future<String> getLocale() async {
    return sky.window.locale.languageCode;
  }

  @override
  Future<double> getDisplayDensity() async {
    return sky.window.devicePixelRatio;
  }

}
