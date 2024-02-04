import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_location/tileManager/store_tiles.dart';

//!!!!!!!!!!
// do not modify or change anything of this file, I'm not done with it yet.
// -Ether
//!!!!!!!!!!
class LocalTileProvider extends TileProvider {
  TileManager _tileManager;
  final _cache = <String, ImageProvider>{};

  LocalTileProvider(this._tileManager);

  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // this is a key for cach map
    String key = "${coordinates.z}_${coordinates.x}_${coordinates.y}";

    // this is for trying to get the image from cach
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    } else {
      // return a network image while the tile is loading:
      return NetworkImage(
        options.urlTemplate!
            .replaceAll("{x}", coordinates.x.toString())
            .replaceAll("{y}", coordinates.y.toString())
            .replaceAll("{z}", coordinates.z.toString())
            .replaceAll("{accessToken}",
                "pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw"),
      );
    }
  }

  void prefetchTile(int x, int y, int z) async {
    String key = "${z}_${x}_${y}";
    // checking if the tile exists locally:
    if (!await _tileManager.tileExists(x, y, z)) {
      await _tileManager.downloadTile(x, y, z);
    }
    var file = await _tileManager.getTileFile(x, y, z);
    _cache[key] = FileImage(file);
  }
}
