import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

class MapWidget extends StatefulWidget {
  final Position? initialPosition;
  final Function(Position) onPositionUpdate;

  const MapWidget({
    super.key,
    this.initialPosition,
    required this.onPositionUpdate,
  });

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  MapController? _mapController;
  Position? _currentPosition;
  Position? _destinationPosition;
  bool _isLoading = true;
  final double _radiusSize = 100.0; // Size of the blue radius circle
  String _distance = "Calculating...";

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _destinationPosition = widget.initialPosition;

    if (_destinationPosition != null) {
      setState(() {
        _isLoading = false;
      });

      // Try to get current location for distance calculation
      _getCurrentLocation();
    }
  }

  String _formatCoordinates(double lat, double lng) {
    return "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
  }

  // Calculate distance between two coordinates in km
  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Format distance to appropriate units (m or km)
  String _formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return "${(distanceInKm * 1000).toStringAsFixed(0)} m";
    } else if (distanceInKm < 10) {
      return "${distanceInKm.toStringAsFixed(1)} km";
    } else {
      return "${distanceInKm.toStringAsFixed(0)} km";
    }
  }

  void _updateDistance() {
    if (_currentPosition != null && _destinationPosition != null) {
      final distanceInKm = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destinationPosition!.latitude,
        _destinationPosition!.longitude,
      );

      setState(() {
        _distance = _formatDistance(distanceInKm);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      _updateDistance();
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _distance = "Unable to calculate";
      });
    }
  }

  void updateLocation(Position position) {
    setState(() {
      _destinationPosition = position;
      _isLoading = false;
    });
    _animateToPosition(position);
    _updateDistance();
    widget.onPositionUpdate(position);
  }

  void _animateToPosition(Position position) {
    _mapController?.move(LatLng(position.latitude, position.longitude), 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'the Location',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_destinationPosition == null)
                  const Center(child: Text('Location unavailable'))
                else
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        _destinationPosition!.latitude,
                        _destinationPosition!.longitude,
                      ),
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      // Blue radius circle
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                              _destinationPosition!.latitude,
                              _destinationPosition!.longitude,
                            ),
                            radius: _radiusSize,
                            color: Colors.blue.withOpacity(0.3),
                            borderColor: Colors.blue.withOpacity(0.7),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      // Location marker at center
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60.0,
                            height: 60.0,
                            point: LatLng(
                              _destinationPosition!.latitude,
                              _destinationPosition!.longitude,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                // My location button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.black),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
                // Distance chip
                if (_currentPosition != null && _destinationPosition != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _distance,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Bottom navigation info panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'PICKUP',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.circle, color: Colors.white, size: 16),
                    ),
                  ),
                  title: const Text(
                    "My current location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      _currentPosition != null
                          ? Text(
                            _formatCoordinates(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                  onTap: _getCurrentLocation,
                ),
                // Distance indicator in between pickup and drop-off
                if (_currentPosition != null && _destinationPosition != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _distance,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'DROP-OFF',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 28,
                  ),
                  title: Text(
                    _destinationPosition != null
                        ? "105 William St, Chicago, US"
                        : "Destination location",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      _destinationPosition != null
                          ? Text(
                            _formatCoordinates(
                              _destinationPosition!.latitude,
                              _destinationPosition!.longitude,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
