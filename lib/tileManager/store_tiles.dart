import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//!!!!!!!!!!
// do not modify or chnge anything of this file, I'm not done with it yet.
// -Ether
//!!!!!!!!!!
class TileManager {
  Future<void> downloadTiles(
      int minZoom, int maxZoom, int minX, int maxX, int minY, int maxY) async {
    for (int z = minZoom; z <= maxZoom; z++) {
      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          await downloadTile(x, y, z);
        }
      }
    }
  }

  Future<void> downloadTile(int x, int y, int z) async {
    var url =
        'https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/$z/$x/$y@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/tiles/${z}_${x}_$y.png';
      var file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      print(
          'failed to download tile: $z/$x/$y with status code: ${response.statusCode}');
    }
  }

  Future<bool> tileExists(int x, int y, int z) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/tiles/${z}_${x}_$y.png';
    var file = File(filePath);
    return await file.exists();
  }

  Future<File> getTileFile(int x, int y, int z) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/tiles/${z}_${x}_$y.png';
    return File(filePath);
  }
} // end of class TileManager
