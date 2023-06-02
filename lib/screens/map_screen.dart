import 'package:flutter/material.dart';

import '../widgets/map_widget.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: MapWidget(latitude: latitude, longitude: longitude),
    );
  }
}
