import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_theme.dart';
import '../../../location/data/location_service.dart';
import '../../../alarm/data/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isAlarmActive = false;
  String _statusMessage = "Enter destination";
  // Position? _currentPosition; // Removed unused field
  double? _targetLat;
  double? _targetLng;
  StreamSubscription<Position>? _positionStream;
  double _distanceInKm = 0.0;
  bool _alarmTriggered = false;

  @override
  void initState() {
    super.initState();
    _initServices();
    _checkPermissions();
  }

  Future<void> _initServices() async {
    await _notificationService.init();
  }

  Future<void> _checkPermissions() async {
    bool hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      setState(() => _statusMessage = "Location permission denied");
    }
  }

  void _toggleAlarm() {
    if (_isAlarmActive) {
      // Stop Alarm
      _stopAlarm();
    } else {
      // Start Alarm
      if (_targetLat == null || _targetLng == null) {
        setState(() => _statusMessage = "Please set a valid destination");
        return;
      }
      _startAlarmMonitoring();
    }
  }

  void _stopAlarm() {
    _positionStream?.cancel();
    _notificationService.stopAlarm();
    setState(() {
      _isAlarmActive = false;
      _alarmTriggered = false;
      _statusMessage = "Alarm stopped";
    });
  }

  void _startAlarmMonitoring() {
    setState(() {
      _isAlarmActive = true;
      _statusMessage = "Tracking location...";
    });

    _positionStream = _locationService.getPositionStream().listen((position) {
      setState(() {
        _currentPosition = position;
        if (_targetLat != null) {
          double distanceMeters = _locationService.calculateDistanceInMeters(
            position.latitude,
            position.longitude,
            _targetLat!,
            _targetLng!,
          );
          _distanceInKm = distanceMeters / 1000;
          _statusMessage = "Distance: ${_distanceInKm.toStringAsFixed(2)} km";

          if (_distanceInKm <= 2.0 && !_alarmTriggered) {
             _triggerAlarm();
          }
        }
      });
    }, onError: (e) {
      setState(() => _statusMessage = "Error getting location: $e");
    });
  }

  void _triggerAlarm() {
    _alarmTriggered = true;
    _notificationService.showAlarmNotification();
    _notificationService.startAlarmSound();
    setState(() => _statusMessage = "ALARM! WAKE UP!");
  }

  Future<void> _searchDestination() async {
    String query = _destinationController.text;
    if (query.isEmpty) return;

    // Hack for demo/web if geocoding fails or just to support direct coordinate input for testing
    // If input contains comma, treat as lat,lng
    if (query.contains(',')) {
      final parts = query.split(',');
      if (parts.length == 2) {
         try {
           double lat = double.parse(parts[0].trim());
           double lng = double.parse(parts[1].trim());
           setState(() {
             _targetLat = lat;
             _targetLng = lng;
             _statusMessage = "Target set: $lat, $lng";
           });
           return;
         } catch(e) {
           // ignore
         }
      }
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        setState(() {
          _targetLat = locations.first.latitude;
          _targetLng = locations.first.longitude;
          _statusMessage = "Target: $query";
        });
      } else {
        setState(() => _statusMessage = "Destination not found");
      }
    } catch (e) {
      setState(() => _statusMessage = "Error searching: $e");
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GeoWake", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.deepBlue,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.deepBlue, AppTheme.lighterBlue],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sleeping Bus Icon
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.sunsetOrange, width: 4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                   BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(4, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/sleeping_bus_icon.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(width: 150, height: 150, color: Colors.grey, child: Icon(Icons.bus_alert, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Search Bar
            TextField(
              controller: _destinationController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter destination (or lat,lng)",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: AppTheme.sunsetOrange),
                  onPressed: _searchDestination,
                ),
              ),
              onSubmitted: (_) => _searchDestination(),
            ),
            const SizedBox(height: 16),

            // Status Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _alarmTriggered ? AppTheme.sunsetOrange : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Alarm Toggle Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _toggleAlarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAlarmActive ? AppTheme.forestGreen : AppTheme.burntOrange,
                ),
                child: Text(
                  _isAlarmActive ? "STOP ALARM" : "ACTIVATE ALARM",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
             if (_isAlarmActive && _targetLat != null)
               Padding(
                 padding: const EdgeInsets.only(top: 20),
                 child: Text(
                   "Target: ${_targetLat!.toStringAsFixed(4)}, ${_targetLng!.toStringAsFixed(4)}",
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                 ),
               )
          ],
        ),
      ),
    );
  }
}
