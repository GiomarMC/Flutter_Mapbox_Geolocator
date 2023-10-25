import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

const mapbox_access_token =
    'pk.eyJ1IjoiZ2lvbWFybWMiLCJhIjoiY2xvM2l1NDF3MWVwdTJzcDlsNW1pZDZ5YSJ9.T_71Il3vOzvZ4rGQkRFGqg';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _HomePageState();
}

class _HomePageState extends State<MapScreen> {
  LatLng myPosition = LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<Position> determinarPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinarPosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Mapa'),
          backgroundColor: Colors.blueAccent,
          actions: [
            ElevatedButton(
                onPressed: () {
                  getCurrentLocation();
                },
                child: const Icon(Icons.refresh)),
          ],
        ),
        body: myPosition != LatLng(0, 0)
            ? FlutterMap(
                options: MapOptions(
                  initialCenter: myPosition,
                  initialZoom: 18,
                  minZoom: 5,
                  maxZoom: 25,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: const {
                      'accessToken': mapbox_access_token,
                      'id': 'mapbox/streets-v12'
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: myPosition,
                        child: const Icon(
                          Icons.person_pin,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
