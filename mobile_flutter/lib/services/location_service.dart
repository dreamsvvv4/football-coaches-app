import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class LatLon {
  final double lat;
  final double lon;
  const LatLon(this.lat, this.lon);
}

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  static const _originLatKey = 'location_origin_lat';
  static const _originLonKey = 'location_origin_lon';
  static const _customVenuesKey = 'location_custom_venues';

  final Map<String, LatLon> _baseCoords = {
    'campo municipal': const LatLon(40.4168, -3.7038),
    'estadio central': const LatLon(40.4175, -3.7034),
    'polideportivo norte': const LatLon(40.45, -3.69),
  };

  final Map<String, LatLon> _coords = {};

  // Reference origin (e.g., user's club/home)
  LatLon origin = const LatLon(40.4168, -3.7038);
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _coords
      ..clear()
      ..addAll(_baseCoords);

    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString(_customVenuesKey);
    if (customJson != null) {
      try {
        final List<dynamic> raw = jsonDecode(customJson) as List<dynamic>;
        for (final item in raw) {
          final map = Map<String, dynamic>.from(item as Map);
          final name = (map['name'] as String?)?.toLowerCase();
          final lat = (map['lat'] as num?)?.toDouble();
          final lon = (map['lon'] as num?)?.toDouble();
          if (name != null && lat != null && lon != null) {
            _coords[name] = LatLon(lat, lon);
          }
        }
      } catch (_) {
        // Ignorar datos corruptos; se regenerarán al guardar de nuevo
      }
    }

    final lat = prefs.getDouble(_originLatKey);
    final lon = prefs.getDouble(_originLonKey);
    if (lat != null && lon != null) {
      origin = LatLon(lat, lon);
    } else {
      origin = _coords['campo municipal'] ?? origin;
    }

    _initialized = true;
  }

  double? distanceKmFor(String locationName) {
    final key = locationName.toLowerCase().trim();
    final coords = _coords[key];
    if (coords == null) return null;
    return _haversine(origin.lat, origin.lon, coords.lat, coords.lon);
  }

  Map<String, LatLon> get venues => Map.unmodifiable(_coords);

  Future<void> setOriginByName(String locationName) async {
    final key = locationName.toLowerCase().trim();
    final coords = _coords[key];
    if (coords != null) {
      origin = coords;
      await _persistOrigin();
    }
  }

  Future<void> setOrigin(LatLon latLon) async {
    origin = latLon;
    await _persistOrigin();
  }

  Future<void> addVenue(String name, LatLon latLon) async {
    final key = name.toLowerCase().trim();
    _coords[key] = latLon;
    await _persistCustomVenues();
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
        math.sin(dLon/2) * math.sin(dLon/2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    return R * c;
  }

  double _toRad(double deg) => deg * math.pi / 180.0;

  Future<void> _persistOrigin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_originLatKey, origin.lat);
    await prefs.setDouble(_originLonKey, origin.lon);
  }

  Future<void> _persistCustomVenues() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = _coords.entries
        .where((e) => !_baseCoords.containsKey(e.key))
        .map((e) => {
              'name': e.key,
              'lat': e.value.lat,
              'lon': e.value.lon,
            })
        .toList();
    await prefs.setString(_customVenuesKey, jsonEncode(custom));
  }
}
