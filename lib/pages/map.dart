import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

//import 'package:test_mapbox/services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController mapController;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mapbox Flutter App'),
      // ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation ??
              LatLng(20.0, 38.0), // Initial center of the map
          initialZoom: 9.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/yorhaether/clrnqwwd9006g01peerp97p8m/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJmbDVrdGIwNHpuMmtydmhpZDNnNHRoIn0.yrhnYgnLmdl_IgfrlI3mxQ',
            additionalOptions: const {
              'accessToken':
                  'pk.eyJ1IjoieW9yaGFldGhlciIsImEiOiJjbHJmbDVrdGIwNHpuMmtydmhpZDNnNHRoIn0.yrhnYgnLmdl_IgfrlI3mxQ',
              'id': 'yorhaether.6vwpkduq',
            },
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: currentLocation ?? LatLng(20.0, 38.0),
                child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
