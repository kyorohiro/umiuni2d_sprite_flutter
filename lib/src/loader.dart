part of umiuni2d_sprite_flutter;



class TinyFlutterImage implements core.Image {
  ImageInfo rawImage;
  TinyFlutterImage(this.rawImage);

  @override
  int get w => rawImage.image.width;

  @override
  int get h => rawImage.image.height;

  @override
  void dispose() {}
}

class ResourceLoader {
  static AssetBundle getAssetBundle() {
    if (rootBundle != null) {
      return rootBundle;
    } else {
      return new NetworkAssetBundle(new Uri.directory(Uri.base.origin));
    }
  }

  static Future<ImageInfo> loadImage(String url) async {
    ImageStream stream = new AssetImage(url, bundle: getAssetBundle()).resolve(ImageConfiguration.empty);
    Completer<ImageInfo> completer = new Completer<ImageInfo>();
    void listener(ImageInfo frame, bool synchronousCall) {
      completer.complete(frame);
    }
    stream.addListener(listener);
    return completer.future;
//    AssetBundle bundle = getAssetBundle();
//    ImageResource resource = bundle.loadImage(url);
//    return resource.first;
  }

  static Future<String> loadString(String url) async {
    AssetBundle bundle = getAssetBundle();
    String b = await bundle.loadString(url);
    //print("-a-${url} -- ${b}");
    return b;
  }

  // TODO
  static Future<data.Uint8List> loadBytes(String url) async {
    AssetBundle bundle = getAssetBundle();
    ByteData b = await bundle.load(url);
    data.ByteData d1 = b;//await DataPipeDrainer.drainHandle(b);
    //print("-a-${url} -- ${b}");
    return d1.buffer.asUint8List();//b;
  }

  static Future<ByteData> loadMojoData(String url) async {
    AssetBundle bundle = getAssetBundle();
    return await bundle.load(url);
  }
}
