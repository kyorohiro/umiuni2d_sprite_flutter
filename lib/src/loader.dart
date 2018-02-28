part of umiuni2d_sprite_flutter;



class TinyFlutterImage implements core.Image {
  flu.ImageInfo rawImage;
  TinyFlutterImage(this.rawImage);

  @override
  int get w => rawImage.image.width;

  @override
  int get h => rawImage.image.height;

  @override
  void dispose() {}
}

class ResourceLoader {
  static flu.AssetBundle getAssetBundle() {
    if (flu.rootBundle != null) {
      return flu.rootBundle;
    } else {
      return new flu.NetworkAssetBundle(new Uri.directory(Uri.base.origin));
    }
  }

  static Future<flu.ImageInfo> loadImage(String url) async {
    flu.ImageStream stream = new flu.AssetImage(url, bundle: getAssetBundle()).resolve(flu.ImageConfiguration.empty);
    Completer<flu.ImageInfo> completer = new Completer<flu.ImageInfo>();
    void listener(flu.ImageInfo frame, bool synchronousCall) {
      completer.complete(frame);
    }
    stream.addListener(listener);
    return completer.future;
  }

  static Future<String> loadString(String url) async {
    flu.AssetBundle bundle = getAssetBundle();
    String b = await bundle.loadString(url);
    //print("-a-${url} -- ${b}");
    return b;
  }

  // TODO
  static Future<data.Uint8List> loadBytes(String url) async {
    flu.AssetBundle bundle = getAssetBundle();
    flu.ByteData b = await bundle.load(url);
    data.ByteData d1 = b;//await DataPipeDrainer.drainHandle(b);
    //print("-a-${url} -- ${b}");
    return d1.buffer.asUint8List();//b;
  }

  static Future<flu.ByteData> loadMojoData(String url) async {
    flu.AssetBundle bundle = getAssetBundle();
    return await bundle.load(url);
  }
}
