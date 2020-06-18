library fos_tracker.globals;

import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng startPosition;
Set<Marker> agentMarkers = new Set();
Set<Marker> merchantMarkers = new Set();
Map<String, dynamic> statusToNumberOfStoresMap = new Map();
int storesRegistered = 0;
int storesVerified = 0;
String region = "ALL";
String regionCategory = "REGION";