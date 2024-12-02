import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pr_h23_irlandes_web/ui/pages/admin/dashboard.dart';



void mapflutter() {
  runApp(MyAppMAPA());
}

class MyAppMAPA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(onLocationSelected: (double lat , double long ) {  },),
    );
  }
}

class MapScreen extends StatefulWidget {
  final Function(double, double) onLocationSelected; // función de devolución de llamada

  MapScreen({required this.onLocationSelected});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {



  Marker? customMarker;

  Marker buildPin(LatLng point) => Marker(
    point: point,
    width: 60,
    height: 60,
    child: GestureDetector(
      onTap: () {
        final lat = point.latitude.toString();
        final lon = point.longitude.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lat: $lat, Lon: $lon'),
            duration: Duration(seconds: 1),
            showCloseIcon: true,
          ),
        );
      },
      child: const Icon(Icons.location_pin, size: 60, color: Colors.black),
    ),
  );

  LatLng getCoordinates() {
    if (customMarker != null) {
      return customMarker!.point;
    } else {
      // Si no hay marcador personalizado, devuelve una ubicación predeterminada
      return LatLng(0, 0);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markers')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(-17.404955 ,-66.139355), // Coordenadas de Bolivia
            initialZoom: 12,
            onTap: (_, p) => setState(() {
              customMarker = buildPin(p);
              widget.onLocationSelected(p.latitude, p.longitude);
            }),
            interactionOptions: InteractionOptions(
              flags: ~InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            if (customMarker != null)
              MarkerLayer(
                markers: [customMarker!],
                // rotate: counterRotate,
                // alignment: selectedAlignment,
              ),
          ],
        ),
      ),
    );
  }
}