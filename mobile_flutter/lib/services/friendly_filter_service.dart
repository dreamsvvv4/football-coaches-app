class FriendlyFilterService {
  static final FriendlyFilterService instance = FriendlyFilterService._();
  FriendlyFilterService._();

  String locationQuery = '';
  double radiusKm = 10;
  String category = 'Alevín';
}
