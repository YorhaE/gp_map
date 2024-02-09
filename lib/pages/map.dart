import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_location/tileManager/store_tiles.dart';
import 'package:test_location/tileManager/local_tile_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController mapController;
  late TileManager tileManager;
  late LocalTileProvider localTileProvider;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    tileManager = TileManager();
    // initilizing local tile provider
    localTileProvider = LocalTileProvider(tileManager,
        "https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw");
    getCurrentLocation().then((_) {
      setState(() {});
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        // request location permission
        locationPermission = await Geolocator.requestPermission();
      }
      // Handle the case where the user has permanently denied location permission
      if (locationPermission == LocationPermission.deniedForever) {
        print("Location permission denied forever");
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (currentLocation != null) {
        mapController.move(currentLocation!, 15.0);
        var bounds = mapController.camera.visibleBounds;
        var zoom = mapController.camera.zoom;
        tileManager.prefetchTiles(bounds, zoom.round());
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation ??
              LatLng(20.0, 38.0), // Initial center of the map
          initialZoom: 9.0, // Initial zoom level
          onMapReady: () {
            print("map is ready!");
            if (currentLocation != null) {
              var bounds = mapController.camera.visibleBounds;
              var zoom = mapController.camera.zoom;
              tileManager.prefetchTiles(bounds, zoom.round());
            }
          },
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture) {
              // triggered when the map is panned or zoomed by the user
              var bounds = mapController.camera.visibleBounds;
              var zoom = mapController.camera.zoom;
              tileManager.prefetchTiles(bounds, zoom.round());
            }
          },
        ), // MapOptions
        children: [
          TileLayer(
            tileProvider: localTileProvider,
            urlTemplate:
                'https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw',
            additionalOptions: const {
              'accessToken':
                  'pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJ4ZjI4ajQwdXZ6Mmp0a3pzZmlxaTloIn0.yiGEwb2lvrqZRFB1QixSYw',
              'id': 'yorhaether.6vwpkduq',
            },
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 48.0,
                height: 48.0,
                point: currentLocation ?? const LatLng(20.0, 38.0),
                child: Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      ),
                      Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70.0, right: 9.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF262626),
        ),
        child: IconButton(
          icon: const Icon(Icons.my_location_outlined),
          color: Colors.white,
          onPressed: () {
            getCurrentLocation();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
