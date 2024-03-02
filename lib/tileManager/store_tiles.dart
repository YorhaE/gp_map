import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TileManager {
  Future<bool> hasNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<File?> downloadTile(int x, int y, int z) async {
    if (!await hasNetwork()) {
      print("No network connectivity. Cannot download tile.");
      return null;
    }
    try {
      final url =
          'https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/${z}/${x}/${y}@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/tiles/${z}_${x}_${y}.png';
        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print(
            'Failed to download tile: $z/$x/$y with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Exception when dowoanloading tile: $e");
      return null;
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
      ;
    }
    return await file.exists();
  }

  Future<File?> getTileFile(int x, int y, int z) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tiles/${z}_${x}_${y}.png';
    final file = File(filePath);

    // Log the attempt to locate the tile file
    print("Looking for tile at path: $filePath");
    if (await file.exists()) {
      print(
          "Tile found: Zoom $z, X $x, Y $y"); // Log success when the tile exists
      return file; //if the tile file exists locally
    } else {
      print("Tile not found, needs fetching: Zoom $z, X $x, Y $y");
      return await downloadTile(x, y, z);
    }
  }

// **new added method** for getting tiles from local storage
  Future<File?> fetchTile(int x, int y, int z) async {
    final localTile = await getTileFile(z, x, y);
    if (localTile != null) {
      return localTile;
    } else {
      return await downloadTile(z, x, y);
    }
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
