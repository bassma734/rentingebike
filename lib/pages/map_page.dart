import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  // Replace these with the actual coordinates of your station location
  final LatLng _stationLocation = const LatLng(34.838598, 10.755920); // Example coordinates for the Empire State Building
  final Set<Marker> _markers = {};
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('_stationLocation'),
          position: _stationLocation,
          infoWindow: const InfoWindow(
            title: 'Station Location',
            snippet: 'the station is here',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _stationLocation,
          zoom: 15.0,
        ),
        markers: _markers,
      ),
    );
  }
}
