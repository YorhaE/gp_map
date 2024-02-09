import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_location/tileManager/store_tiles.dart';

//!!!!!!!!!!
// do not modify or change anything of this file, I'm not done with it yet.
// -Ether
//!!!!!!!!!!
class LocalTileProvider extends TileProvider {
  final TileManager _tileManager;
  final _cache = <String, ImageProvider>{};
  final String urlTemplate;

  LocalTileProvider(this._tileManager, this.urlTemplate);

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
            .replaceAll("{z}", coordinates.z.toString())
            .replaceAll("{x}", coordinates.x.toString())
            .replaceAll("{y}", coordinates.y.toString()),
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
