
import 'package:flutter/services.dart';

class AssetUtil {
  static Future<String> getAsset(String filePath) async {
    var content = await rootBundle.loadString("assets/$filePath", cache: true);

    return Future.value(content);
  }
}