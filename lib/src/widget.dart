part of umiuni2d_sprite_flutter;

class GameWidget extends flu.SingleChildRenderObjectWidget implements core.GameWidget {
  core.Stage _stage;
  core.Stage get stage => _stage;
  Map<String, Object> objects = {};

  core.OnStart onStart = null;
  core.OnLoop onLoop = null;


  GameWidget({
    core.DisplayObject root,
    core.DisplayObject background,
    core.DisplayObject front,
    double width:400.0,
    double height:300.0,
    this.assetsRoot: "web/"}) {
    if(root == null) {
      root = new core.GameRoot(width, height);
    }
    this._stage = this.createStage(root: root, background: background, front: front);
  }

  @override
  flu.RenderObject createRenderObject(flu.BuildContext context) {
    return (stage as TinyFlutterStage);
  }

  bool _isRun = false;
  void run() {
    if(_isRun == false) {
      flu.runApp(this);
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
  core.Stage createStage({core.DisplayObject root, core.DisplayObject background,core.DisplayObject front}) {
    if(root == null) {
      root = new core.DisplayObject();
    }
    return new TinyFlutterStage(this, root, background, front);
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

  Future<core.ImageShader> createImageShader(core.Image image) async {
    return null;
  }
}
