import '../models/restaurant.dart';
import 'api_service.dart';

class RestaurantService {
  final ApiService _api = ApiService();

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants({
    String? status,
    int? limit,
    String? category,
  }) async {
    final filters = <String, dynamic>{};
    if (status != null) filters['status'] = status;
    if (category != null) filters['categories'] = category;

    return await _api.query<Restaurant>(
      table: 'restaurants',
      fromJson: Restaurant.fromJson,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      filters: filters.isEmpty ? null : filters,
    );
  }

  // Get restaurant by ID
  Future<Restaurant?> getRestaurantById(String id) async {
    return await _api.getById<Restaurant>(
      table: 'restaurants',
      id: id,
      fromJson: Restaurant.fromJson,
    );
  }

  // Get restaurants by owner
  Future<List<Restaurant>> getRestaurantsByOwner(String ownerId) async {
    return await _api.query<Restaurant>(
      table: 'restaurants',
      fromJson: Restaurant.fromJson,
      orderBy: 'created_at',
      ascending: false,
      filters: {'owner_id': ownerId},
    );
  }

  // Get nearby restaurants
  Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  }) async {
    try {
      final response = await _api.client.rpc(
        'get_nearby_restaurants',
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusInKm,
        },
      );

      return (response as List)
          .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If RPC doesn't exist, fall back to getting all active restaurants
      return await getRestaurants(status: 'active');
    }
  }

  // Create restaurant
  Future<Restaurant> createRestaurant(Restaurant restaurant) async {
    return await _api.insert<Restaurant>(
      table: 'restaurants',
      data: restaurant.toJson(),
      fromJson: Restaurant.fromJson,
    );
  }

  // Update restaurant
  Future<Restaurant> updateRestaurant(Restaurant restaurant) async {
    return await _api.update<Restaurant>(
      table: 'restaurants',
      id: restaurant.id,
      data: restaurant.toJson(),
      fromJson: Restaurant.fromJson,
    );
  }

  // Delete restaurant
  Future<void> deleteRestaurant(String id) async {
    await _api.delete(
      table: 'restaurants',
      id: id,
    );
  }

  // Search restaurants
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await _api.client
          .from('restaurants')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Failed to search restaurants: $e');
    }
  }

  // Upload restaurant logo
  Future<String> uploadLogo(String restaurantId, dynamic file) async {
    final path = 'restaurants/$restaurantId/logo_${DateTime.now().millisecondsSinceEpoch}';
    return await _api.uploadFile(
      bucket: 'restaurant-media',
      path: path,
      file: file,
    );
  }

  // Upload restaurant cover image
  Future<String> uploadCoverImage(String restaurantId, dynamic file) async {
    final path = 'restaurants/$restaurantId/cover_${DateTime.now().millisecondsSinceEpoch}';
    return await _api.uploadFile(
      bucket: 'restaurant-media',
      path: path,
      file: file,
    );
  }
}
