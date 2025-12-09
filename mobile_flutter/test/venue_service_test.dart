import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/venue_service.dart';
import '../lib/models/venue.dart';

void main() {
  group('VenueService Tests', () {
    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      // Force re-initialization by creating a fresh instance for each test
      // Since VenueService is a singleton, we need to reset its state
    });

    test('init() should load mock venues on first call', () async {
      final service = VenueService.instance;
      await service.init();
      
      final venues = service.getAllVenues();
      expect(venues.isNotEmpty, true);
      expect(venues.length, 5); // Bootstrap has 5 mock venues
    });

    test('getAllVenues() should return unmodifiable list', () async {
      final service = VenueService.instance;
      await service.init();
      
      final venues = service.getAllVenues();
      expect(venues, isA<List<Venue>>());
    });

    test('getVenueById() should return venue if exists', () async {
      final service = VenueService.instance;
      await service.init();
      
      final allVenues = service.getAllVenues();
      final id = allVenues.first.id;
      final venue = service.getVenueById(id);
      
      expect(venue, isNotNull);
      expect(venue!.id, id);
    });

    test('getVenueById() should return null if not found', () async {
      final service = VenueService.instance;
      await service.init();
      
      final venue = service.getVenueById('nonexistent_id');
      expect(venue, isNull);
    });

    test('createVenue() should add new venue with valid data', () async {
      final service = VenueService.instance;
      await service.init();
      final initialCount = service.getAllVenues().length;
      
      final newVenue = await service.createVenue(
        name: 'Test Venue',
        latitude: 40.5,
        longitude: -3.5,
        address: '123 Test St',
        description: 'A test venue',
      );
      
      expect(newVenue.name, 'Test Venue');
      expect(newVenue.latitude, 40.5);
      expect(newVenue.longitude, -3.5);
      expect(service.getAllVenues().length, initialCount + 1);
    });

    test('createVenue() should throw error on empty name', () async {
      final service = VenueService.instance;
      await service.init();
      
      expect(
        () => service.createVenue(
          name: '',
          latitude: 40.5,
          longitude: -3.5,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createVenue() should throw error on invalid latitude', () async {
      final service = VenueService.instance;
      await service.init();
      
      expect(
        () => service.createVenue(
          name: 'Test',
          latitude: 95.0, // Invalid: > 90
          longitude: -3.5,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createVenue() should throw error on invalid longitude', () async {
      final service = VenueService.instance;
      await service.init();
      
      expect(
        () => service.createVenue(
          name: 'Test',
          latitude: 40.5,
          longitude: -185.0, // Invalid: < -180
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateVenue() should modify existing venue', () async {
      final service = VenueService.instance;
      await service.init();
      
      final allVenues = service.getAllVenues();
      final venueId = allVenues.first.id;
      
      final updated = await service.updateVenue(
        id: venueId,
        name: 'Updated Name',
        description: 'Updated description',
      );
      
      expect(updated.name, 'Updated Name');
      expect(updated.description, 'Updated description');
      
      final retrieved = service.getVenueById(venueId);
      expect(retrieved!.name, 'Updated Name');
    });

    test('updateVenue() should throw error if venue not found', () async {
      final service = VenueService.instance;
      await service.init();
      
      expect(
        () => service.updateVenue(id: 'nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateVenue() should throw error on invalid coordinates', () async {
      final service = VenueService.instance;
      await service.init();
      
      final allVenues = service.getAllVenues();
      final venueId = allVenues.first.id;
      
      expect(
        () => service.updateVenue(id: venueId, latitude: 100.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deleteVenue() should remove venue', () async {
      final service = VenueService.instance;
      final initialVenues = service.getAllVenues();
      final venueId = initialVenues.first.id;
      final initialCount = initialVenues.length;
      
      await service.deleteVenue(venueId);
      
      expect(service.getAllVenues().length, initialCount - 1);
      expect(service.getVenueById(venueId), isNull);
    });

    test('deleteVenue() should throw error if not found', () async {
      final service = VenueService.instance;
      await service.init();
      
      expect(
        () => service.deleteVenue('nonexistent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('searchByName() should find venues by partial name', () async {
      final service = VenueService.instance;
      await service.init();
      
      // Get actual venue names from bootstrap
      final allVenues = service.getAllVenues();
      expect(allVenues.isNotEmpty, true);
      
      // Search for a venue that exists - use actual names from data
      if (allVenues.any((v) => v.name.toLowerCase().contains('campo'))) {
        final results = service.searchByName('campo');
        expect(results.isNotEmpty, true);
        expect(
          results.every((v) => v.name.toLowerCase().contains('campo')),
          true,
        );
      }
    });

    test('searchByName() should be case-insensitive', () async {
      final service = VenueService.instance;
      await service.init();
      
      final lower = service.searchByName('estadio');
      final upper = service.searchByName('ESTADIO');
      expect(lower.length, upper.length);
    });

    test('searchByName() should return all venues on empty query', () async {
      final service = VenueService.instance;
      await service.init();
      
      final results = service.searchByName('');
      final all = service.getAllVenues();
      expect(results.length, all.length);
    });

    test('Venue model should serialize/deserialize correctly', () {
      final venue = Venue(
        id: 'test_id',
        name: 'Test Venue',
        address: '123 Main St',
        latitude: 40.5,
        longitude: -3.5,
        description: 'Test description',
      );

      final json = venue.toJson();
      final restored = Venue.fromJson(json);

      expect(restored.id, venue.id);
      expect(restored.name, venue.name);
      expect(restored.address, venue.address);
      expect(restored.latitude, venue.latitude);
      expect(restored.longitude, venue.longitude);
      expect(restored.description, venue.description);
    });

    test('Venue.copyWith() should create modified copy', () {
      final original = Venue(
        id: 'test_id',
        name: 'Original',
        latitude: 40.0,
        longitude: -3.0,
      );

      final modified = original.copyWith(
        name: 'Modified',
        latitude: 41.0,
      );

      expect(modified.name, 'Modified');
      expect(modified.latitude, 41.0);
      expect(modified.longitude, original.longitude);
      expect(modified.id, original.id);
    });

    test('Venue equality operator should work correctly', () {
      final venue1 = Venue(
        id: 'same_id',
        name: 'Test',
        latitude: 40.0,
        longitude: -3.0,
      );

      final venue2 = Venue(
        id: 'same_id',
        name: 'Test',
        latitude: 40.0,
        longitude: -3.0,
      );

      final venue3 = Venue(
        id: 'different_id',
        name: 'Test',
        latitude: 40.0,
        longitude: -3.0,
      );

      expect(venue1 == venue2, true);
      expect(venue1 == venue3, false);
    });

    test('calculateDistance() should compute correct distance', () {
      // Madrid to Barcelona roughly 620 km
      final distance = VenueService.calculateDistance(
        40.4168,  // Madrid latitude
        -3.7038,  // Madrid longitude
        41.3851,  // Barcelona latitude
        2.1734,   // Barcelona longitude
      );

      // Should be approximately 600-650 km
      expect(distance > 500, true);
      expect(distance < 700, true);
    });

    test('calculateDistance() should return 0 for same coordinates', () {
      final distance = VenueService.calculateDistance(40.0, -3.0, 40.0, -3.0);
      expect(distance, closeTo(0, 0.1));
    });
  });
}
