part of umiuni2d_sprite_flutter;

class TinyFlutterStage extends RenderConstrainedBox implements core.Stage {
  core.StageBase stageBase;
  TinyFlutterStage(this._builder, core.DisplayObject root,
    {
      this.useDrawVertexForPrimtive: false, this.tickInterval: 15}
    ) : super(additionalConstraints: const BoxConstraints.expand())
      {
    stageBase = new core.StageBase(this);
    this.root = root;
    this.canvas = null;
    init();
  }


  @override
  double get x => paintBounds.left;

  @override
  double get y => paintBounds.top;

  @override
  double get w => paintBounds.width;

  @override
  double get h => paintBounds.height;

  @override
  double get paddingTop => sky.window.padding.top / sky.window.devicePixelRatio;

  @override
  double get paddingBottom => sky.window.padding.bottom / sky.window.devicePixelRatio;

  @override
  double get paddingRight => sky.window.padding.right / sky.window.devicePixelRatio;

  @override
  double get paddingLeft => sky.window.padding.left / sky.window.devicePixelRatio;

  @override
  double get deviceRadio => sky.window.devicePixelRatio;

  @override
  bool animeIsStart = false;

  @override
  int animeId = 0;

  @override
  bool startable = false;

  @override
  bool isInit = false;

  static const int kMaxOfTouch = 5;
  Map<int, TouchPoint> touchPoints = {};

  core.GameWidget _builder;

  @override
  core.GameWidget get builder => _builder;
  core.Canvas canvas;
  bool useDrawVertexForPrimtive;
  int tickInterval;


  void init() {}

  @override
  void updateSize(double w, double h) {
    root.changeStageStatus(this, null);
  }

  @override
  void start() {
    if (animeIsStart == true) {
      return;
    }
    isInit = false;
    animeIsStart = true;
    animeId = SchedulerBinding.instance.scheduleFrameCallback(_innerTick);
  }

 @override
 void markPaintshot() {
   if(animeIsStart == true ) {
    return;
   }
   this.markNeedsPaint();
 }

  int timeCount = 0;
  int timeEpoc = 0;
  void _innerTick(Duration timeStamp) {
    //
    // kick timeframe event
    //
    if (startable) {
      kick(timeStamp.inMilliseconds);
    }
    this.markNeedsPaint();
    if (animeIsStart == true) {
      animeId = SchedulerBinding.instance.scheduleFrameCallback(_innerTick);
    }

    //
    // calc fps
    //
    if (timeEpoc == 0) {
      timeEpoc = timeStamp.inMilliseconds;
      timeCount = 0;
    }
    if (timeCount > 60) {
      int cTimeEpoc = timeStamp.inMilliseconds;
      if (cTimeEpoc - timeEpoc != 0) {
        print("fps[A]? : ${1000~/((cTimeEpoc-timeEpoc)/timeCount)} ${timeCount} ${(cTimeEpoc-timeEpoc)/timeCount}");
      }
      timeCount = 0;
      timeEpoc = cTimeEpoc;
    }
    timeCount++;

  }

  @override
  void stop() {
    if (animeIsStart == true && animeId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(animeId);
    }
    animeIsStart = false;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    startable = true;
  }

  @override
  bool hitTest(HitTestResult result, {Offset position}) {
    result.add(new BoxHitTestEntry(this, position));
    return true;
  }

  @override
  bool hitTestSelf(sky.Offset position) => true;

  int kickCountForPaint = 0;
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (this.canvas == null) {
        this.canvas = new TinyFlutterNCanvas(context.canvas, useDrawVertexForPrimtive: useDrawVertexForPrimtive);
    }
    if (startable && kickCountForPaint <= 0) {
      kick(new DateTime.now().millisecondsSinceEpoch);
    }
    kickCountForPaint = 0;
    (this.canvas as TinyFlutterNCanvas).canvas = context.canvas;
    this.canvas.clear();
    kickPaint(this, this.canvas);
    this.canvas.flush();
  }

  core.StagePointerType toEvent(PointerEvent e) {
    if (e is PointerUpEvent) {
      return core.StagePointerType.UP;
    } else if (e is PointerDownEvent) {
      return core.StagePointerType.DOWN;
    } else if (e is PointerCancelEvent) {
      return core.StagePointerType.CANCEL;
    } else if (e is PointerMoveEvent) {
      return core.StagePointerType.MOVE;
    } else if (e is PointerUpEvent) {
      return core.StagePointerType.UP;
    } else {
      return core.StagePointerType.CANCEL;
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry en) {
    if (!(event is PointerEvent || !(en is BoxHitTestEntry))) {
      return;
    }

    BoxHitTestEntry entry = en;
    PointerEvent e = event;
    if (!touchPoints.containsKey(e.pointer)) {
      touchPoints[e.pointer] = new TouchPoint(-1.0, -1.0);
    }

    if (event is PointerDownEvent) {
      touchPoints[e.pointer].x = entry.localPosition.dx;
      touchPoints[e.pointer].y = entry.localPosition.dy;
    } else {
      touchPoints[e.pointer].x = e.position.dx;
      touchPoints[e.pointer].y = e.position.dy;
    }
    kickTouch(this, e.pointer, toEvent(event), touchPoints[e.pointer].x, touchPoints[e.pointer].y);

    if (event is PointerUpEvent) {
      touchPoints.remove(e.pointer);
    }

    if (event is PointerCancelEvent) {
      touchPoints.clear();
    }
  }

  //
  //
  //
  //
  @override
  core.DisplayObject get root => stageBase.root;

  @override
  void set root(core.DisplayObject v) {
    stageBase.root = v;
  }

  @override
  void kick(int timeStamp) {
    kickCountForPaint++;
    stageBase.kick(timeStamp);
  }

  @override
  void kickPaint(core.Stage stage, core.Canvas canvas) {
    stageBase.kickPaint(stage, canvas);
  }

  @override
  void kickTouch(core.Stage stage, int id, core.StagePointerType type, double x, double y) {
    stageBase.kickTouch(stage, id, type, x, y);
  }

  @override
  List<Matrix4> get mats => stageBase.mats;

  @override
  pushMulMatrix(Matrix4 mat) {
    return stageBase.pushMulMatrix(mat);
  }

  @override
  popMatrix() {
    return stageBase.popMatrix();
  }

  @override
  Matrix4 getMatrix() {
    return stageBase.getMatrix();
  }

  @override
  double get xFromMat => stageBase.xFromMat;

  @override
  double get yFromMat => stageBase.yFromMat;

  @override
  double get zFromMat => stageBase.zFromMat;

  @override
  double get sxFromMat => stageBase.sxFromMat;

  @override
  double get syFromMat => stageBase.syFromMat;

  @override
  double get szFromMat => stageBase.szFromMat;

  @override
  Vector3 getCurrentPositionOnDisplayObject(double globalX, double globalY) {
    return stageBase.getCurrentPositionOnDisplayObject(globalX, globalY);
  }
}

class TouchPoint {
  double x;
  double y;
  TouchPoint(this.x, this.y);
}
