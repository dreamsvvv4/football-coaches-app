import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/venue.dart';

class VenueService {
  static final VenueService instance = VenueService._internal();
  VenueService._internal();

  static const String _venuesKey = 'venues_list';

  final List<Venue> _venues = [];
  bool _initialized = false;

  /// Initialize service with mock data and load persisted venues
  Future<void> init() async {
    if (_initialized) return;

    // Load mock/persisted venues
    await _loadVenues();

    // If empty, bootstrap with mock data
    if (_venues.isEmpty) {
      await _bootstrapMockData();
    }

    _initialized = true;
  }

  /// Get all venues
  List<Venue> getAllVenues() => List.unmodifiable(_venues);

  /// Get venue by ID
  Venue? getVenueById(String id) {
    try {
      return _venues.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new venue and persist
  Future<Venue> createVenue({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
  }) async {
    // Validation
    if (name.isEmpty) throw ArgumentError('Venue name cannot be empty');
    if (latitude < -90 || latitude > 90) throw ArgumentError('Invalid latitude');
    if (longitude < -180 || longitude > 180) throw ArgumentError('Invalid longitude');

    final venue = Venue(
      id: _generateId(),
      name: name.trim(),
      address: address?.trim(),
      latitude: latitude,
      longitude: longitude,
      description: description?.trim(),
    );

    _venues.add(venue);
    await _persistVenues();
    return venue;
  }

  /// Update an existing venue
  Future<Venue> updateVenue({
    required String id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
  }) async {
    final index = _venues.indexWhere((v) => v.id == id);
    if (index == -1) throw ArgumentError('Venue not found');

    final current = _venues[index];

    // Validation for updates
    if (name != null && name.isEmpty) throw ArgumentError('Venue name cannot be empty');
    if (latitude != null && (latitude < -90 || latitude > 90)) {
      throw ArgumentError('Invalid latitude');
    }
    if (longitude != null && (longitude < -180 || longitude > 180)) {
      throw ArgumentError('Invalid longitude');
    }

    final updated = current.copyWith(
      name: name?.trim() ?? current.name,
      latitude: latitude ?? current.latitude,
      longitude: longitude ?? current.longitude,
      address: address?.trim() ?? current.address,
      description: description?.trim() ?? current.description,
      updatedAt: DateTime.now(),
    );

    _venues[index] = updated;
    await _persistVenues();
    return updated;
  }

  /// Delete a venue by ID
  Future<void> deleteVenue(String id) async {
    final index = _venues.indexWhere((v) => v.id == id);
    if (index == -1) throw ArgumentError('Venue not found');

    _venues.removeAt(index);
    await _persistVenues();
  }

  /// Search venues by name (case-insensitive)
  List<Venue> searchByName(String query) {
    if (query.isEmpty) return _venues;
    final lower = query.toLowerCase();
    return _venues.where((v) => v.name.toLowerCase().contains(lower)).toList();
  }

  /// Calculate distance between two coordinates (Haversine formula, returns km)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * (3.14159265359 / 180);

  static double sin(double x) {
    // Approximation for sin (adequate for small angles)
    return x - (x * x * x / 6) + (x * x * x * x * x / 120);
  }

  static double cos(double x) {
    // Approximation for cos
    return 1 - (x * x / 2) + (x * x * x * x / 24);
  }

  static double sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    double res = x;
    for (int i = 0; i < 10; i++) {
      res = (res + x / res) / 2;
    }
    return res;
  }

  static double atan2(double y, double x) {
    // Approximation for atan2
    if (x > 0) return atan(y / x);
    if (x < 0 && y >= 0) return atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return atan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0;
  }

  static double atan(double x) {
    // Approximation for atan
    return x - (x * x * x / 3) + (x * x * x * x * x / 5);
  }

  /// Private helpers
  Future<void> _loadVenues() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_venuesKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        _venues.clear();
        for (final item in list) {
          final map = Map<String, dynamic>.from(item as Map);
          _venues.add(Venue.fromJson(map));
        }
      } catch (_) {
        // Ignore malformed data
        _venues.clear();
      }
    }
  }

  Future<void> _persistVenues() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_venues.map((v) => v.toJson()).toList());
    await prefs.setString(_venuesKey, json);
  }

  Future<void> _bootstrapMockData() async {
    final mockVenues = [
      Venue(
        id: 'venue_mock_1',
        name: 'Campo Municipal Centro',
        address: 'Calle Principal 123, Madrid',
        latitude: 40.4168,
        longitude: -3.7038,
        description: 'Campo con 2 pistas de fútbol 7',
      ),
      Venue(
        id: 'venue_mock_2',
        name: 'Estadio Central',
        address: 'Avenida del Deporte 456, Madrid',
        latitude: 40.4175,
        longitude: -3.7034,
        description: 'Estadio de capacidad 500 personas',
      ),
      Venue(
        id: 'venue_mock_3',
        name: 'Polideportivo Norte',
        address: 'Plaza Deportiva 789, Madrid',
        latitude: 40.4500,
        longitude: -3.6900,
        description: 'Pistas múltiples, cancha cubierta',
      ),
      Venue(
        id: 'venue_mock_4',
        name: 'Complejo Sur',
        address: 'Barrio Sur 321, Madrid',
        latitude: 40.3900,
        longitude: -3.7100,
        description: 'Instalación completa con vestuarios',
      ),
      Venue(
        id: 'venue_mock_5',
        name: 'Cancha Barrial Este',
        address: 'Zona Este 654, Madrid',
        latitude: 40.4300,
        longitude: -3.6800,
        description: 'Campo comunitario',
      ),
    ];

    _venues.addAll(mockVenues);
    await _persistVenues();
  }

  String _generateId() => 'venue_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
}
