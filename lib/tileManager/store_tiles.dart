import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TileManager {
  Future<void> downloadTile(int x, int y, int z) async {
    var url =
        'https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/${z}/${x}/${y}@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw';
    var response;
    print('Request URL: $url');
    try {
      response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('HTTP request error: $e');
    }
    if (response.statusCode == 200) {
      var directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/tiles/${z}_${x}_${y}.png';
      var file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      print(
          'Error downloading tile: $z/$x/$y, Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<bool> tileExists(int x, int y, int z) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/tiles/${z}_${x}_${y}.png';
    var file = File(filePath);
    if (await file.exists()) {
      print('Tile exixts locally: $filePath');
    } else {
      print('Tile does not exist locally, downloading: ${z}/${x}/${y}');
    }
    return await file.exists();
  }

  Future<File> getTileFile(int x, int y, int z) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/tiles/${z}_${x}_${y}.png';
    return File(filePath);
  }

  Future<void> prefetchTiles(LatLngBounds bounds, int zoom) async {
    int minTileX = _longitudeToTileX(bounds.west, zoom);
    int maxTileX = _longitudeToTileX(bounds.east, zoom);
    int minTileY = _latitudeToTileY(bounds.north, zoom);
    int maxTileY = _latitudeToTileY(bounds.south, zoom);

    for (int x = minTileX; x <= maxTileX; x++) {
      for (int y = minTileY; y <= maxTileY; y++) {
        if (!await tileExists(x, y, zoom)) {
          await downloadTile(x, y, zoom);
        }
      }
    }
  }

  int _longitudeToTileX(double longitude, int zoom) {
    return ((longitude + 180) / 360 * pow(2, zoom)).floor();
  }

  int _latitudeToTileY(double latitude, int zoom) {
    double latRad = latitude * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * pow(2, zoom))
        .floor();
  }
} // end of class TileManager
