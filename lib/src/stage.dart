part of umiuni2d_sprite_flutter;

class TinyFlutterStage extends flu.RenderConstrainedBox implements core.Stage {
  core.StageBase stageBase;
  TinyFlutterStage(this._context,
      core.DisplayObject root,core.DisplayObject background,core.DisplayObject front,
    {
      this.tickInterval: 15}
    ) : super(additionalConstraints: const flu.BoxConstraints.expand())
      {
    stageBase = new core.StageBase(this, root, background, front);
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

  GameWidget _context;

  @override
  core.GameWidget get context => _context;
  core.Canvas canvas;
  int tickInterval;


  void init() {}

  @override
  void updateSize(double w, double h) {
    background.changeStageStatus(this, null);
    root.changeStageStatus(this, null);
    front.changeStageStatus(this, null);
  }

  @override
  void start() {
    if (animeIsStart == true) {
      return;
    }
    isInit = false;
    animeIsStart = true;
    animeId = flu.SchedulerBinding.instance.scheduleFrameCallback(_innerTick);
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
      animeId = flu.SchedulerBinding.instance.scheduleFrameCallback(_innerTick);
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
        print("fps[A]? : ${1000~/((cTimeEpoc-timeEpoc)/timeCount)} ${timeCount.toString()} ${(cTimeEpoc-timeEpoc)/timeCount}");
      }
      timeCount = 0;
      timeEpoc = cTimeEpoc;
    }
    timeCount++;

  }

  @override
  void stop() {
    if (animeIsStart == true && animeId != null) {
      flu.SchedulerBinding.instance.cancelFrameCallbackWithId(animeId);
    }
    animeIsStart = false;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    startable = true;
    print(">>>test>>> " + w.toString() + " " + h.toString());
    new Future((){
      try {
        this.updateSize(w, h);
      } catch(e){}
    });
  }

  @override
  bool hitTest(flu.HitTestResult result, {flu.Offset position}) {
    result.add(new flu.BoxHitTestEntry(this, position));
    return true;
  }

  @override
  bool hitTestSelf(sky.Offset position) => true;

  int kickCountForPaint = 0;
  @override
  void paint(flu.PaintingContext context, flu.Offset offset) {
    super.paint(context, offset);
    if (this.canvas == null) {
        this.canvas = new TinyFlutterNCanvas(context.canvas);
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

  core.StagePointerType toEvent(flu.PointerEvent e) {
    if (e is flu.PointerUpEvent) {
      return core.StagePointerType.UP;
    } else if (e is flu.PointerDownEvent) {
      return core.StagePointerType.DOWN;
    } else if (e is flu.PointerCancelEvent) {
      return core.StagePointerType.CANCEL;
    } else if (e is flu.PointerMoveEvent) {
      return core.StagePointerType.MOVE;
    } else if (e is flu.PointerUpEvent) {
      return core.StagePointerType.UP;
    } else {
      return core.StagePointerType.CANCEL;
    }
  }

  @override
  void handleEvent(flu.PointerEvent event, flu.HitTestEntry en) {
    if (!(event is flu.PointerEvent || !(en is flu.BoxHitTestEntry))) {
      return;
    }

    flu.BoxHitTestEntry entry = en;
    flu.PointerEvent e = event;
    if (!touchPoints.containsKey(e.pointer)) {
      touchPoints[e.pointer] = new TouchPoint(-1.0, -1.0);
    }

    if (event is flu.PointerDownEvent) {
      touchPoints[e.pointer].x = entry.localPosition.dx;
      touchPoints[e.pointer].y = entry.localPosition.dy;
    } else {
      touchPoints[e.pointer].x = e.position.dx;
      touchPoints[e.pointer].y = e.position.dy;
    }
    kickTouch(this, e.pointer, toEvent(event), touchPoints[e.pointer].x, touchPoints[e.pointer].y);

    if (event is flu.PointerUpEvent) {
      touchPoints.remove(e.pointer);
    }

    if (event is flu.PointerCancelEvent) {
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
  core.DisplayObject get background => stageBase.background;

  @override
  core.DisplayObject get front => stageBase.front;

  @override
  set root(core.DisplayObject v) {
    stageBase.root = v;
  }

  set background(core.DisplayObject v) {
    stageBase.background = v;
  }

  set front(core.DisplayObject v) {
    stageBase.front = v;
  }


  @override
  void kick(int timeStamp) {
    if (!startable) {
      return;
    }
    if(this._context.onLoop != null) {
      this._context.onLoop(this._context);
    }
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

  Matrix4 getMatrix() {
    return stageBase.getMatrix();
  }

  @override
  Vector3 getCurrentPositionOnDisplayObject(double globalX, double globalY) {
    return stageBase.getCurrentPositionOnDisplayObject(globalX, globalY);
  }

  core.KeyEventButton createKeyEventButton(String key) {
    return stageBase.createKeyEventButton(key);
  }

  List<core.KeyEventButton> getKeyEventButtonList(String key) {
    return stageBase.getKeyEventButtonList(key);
  }
}

class TouchPoint {
  double x;
  double y;
  TouchPoint(this.x, this.y);
}
