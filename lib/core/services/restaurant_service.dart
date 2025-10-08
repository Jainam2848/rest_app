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
    return await _api.create<Restaurant>(
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
    await _api.delete(table: 'restaurants', id: id);
  }

  // Get restaurant analytics
  Future<Map<String, dynamic>> getRestaurantAnalytics(String restaurantId) async {
    try {
      final response = await _api.client.rpc(
        'get_restaurant_analytics',
        params: {'restaurant_uuid': restaurantId},
      );
      
      return response as Map<String, dynamic>;
    } catch (e) {
      // Fallback to manual calculation if RPC doesn't exist
      return await _calculateRestaurantAnalytics(restaurantId);
    }
  }

  // Fallback analytics calculation
  Future<Map<String, dynamic>> _calculateRestaurantAnalytics(String restaurantId) async {
    try {
      // Get basic counts
      final couponsResponse = await _api.client
          .from('coupons')
          .select('id, is_active')
          .eq('restaurant_id', restaurantId);
      
      final redemptionsResponse = await _api.client
          .from('coupon_redemptions')
          .select('id, user_id')
          .eq('restaurant_id', restaurantId);
      
      final viewsResponse = await _api.client
          .from('coupon_views')
          .select('id')
          .inFilter('coupon_id', (couponsResponse as List)
              .map((c) => c['id'])
              .toList());
      
      final favoritesResponse = await _api.client
          .from('coupon_favorites')
          .select('id')
          .inFilter('coupon_id', (couponsResponse as List)
              .map((c) => c['id'])
              .toList());

      final totalCoupons = (couponsResponse as List).length;
      final activeCoupons = (couponsResponse as List)
          .where((c) => c['is_active'] == true)
          .length;
      final totalRedemptions = (redemptionsResponse as List).length;
      final totalViews = (viewsResponse as List).length;
      final totalFavorites = (favoritesResponse as List).length;
      final uniqueCustomers = (redemptionsResponse as List)
          .map((r) => r['user_id'])
          .toSet()
          .length;

      return {
        'total_coupons': totalCoupons,
        'active_coupons': activeCoupons,
        'total_redemptions': totalRedemptions,
        'total_views': totalViews,
        'total_favorites': totalFavorites,
        'unique_customers': uniqueCustomers,
        'conversion_rate': totalViews > 0 ? (totalRedemptions / totalViews) : 0.0,
        'average_views_per_coupon': totalCoupons > 0 ? (totalViews / totalCoupons) : 0.0,
        'average_redemptions_per_coupon': totalCoupons > 0 ? (totalRedemptions / totalCoupons) : 0.0,
      };
    } catch (e) {
      return {
        'total_coupons': 0,
        'active_coupons': 0,
        'total_redemptions': 0,
        'total_views': 0,
        'total_favorites': 0,
        'unique_customers': 0,
        'conversion_rate': 0.0,
        'average_views_per_coupon': 0.0,
        'average_redemptions_per_coupon': 0.0,
      };
    }
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
      throw Exception('Failed to search restaurants: $e');
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