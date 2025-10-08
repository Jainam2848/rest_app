import '../models/coupon.dart';
import '../models/coupon_redemption.dart';
import 'api_service.dart';

class CouponService {
  final ApiService _api = ApiService();

  // Get all coupons
  Future<List<Coupon>> getCoupons({
    String? restaurantId,
    String? status,
    bool? isActive,
    int? limit,
  }) async {
    final filters = <String, dynamic>{};
    if (restaurantId != null) filters['restaurant_id'] = restaurantId;
    if (status != null) filters['status'] = status;
    if (isActive != null) filters['is_active'] = isActive;

    return await _api.query<Coupon>(
      table: 'coupons',
      fromJson: Coupon.fromJson,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      filters: filters.isEmpty ? null : filters,
    );
  }

  // Get coupon by ID
  Future<Coupon?> getCouponById(String id) async {
    return await _api.getById<Coupon>(
      table: 'coupons',
      id: id,
      fromJson: Coupon.fromJson,
    );
  }

  // Get featured coupons
  Future<List<Coupon>> getFeaturedCoupons({int limit = 10}) async {
    return await _api.query<Coupon>(
      table: 'coupons',
      fromJson: Coupon.fromJson,
      orderBy: 'priority',
      ascending: false,
      limit: limit,
      filters: {'is_featured': true, 'is_active': true},
    );
  }

  // Get active coupons for a restaurant
  Future<List<Coupon>> getActiveCoupons(String restaurantId) async {
    try {
      final response = await _api.client
          .from('coupons')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_active', true)
          .lte('start_date', DateTime.now().toIso8601String())
          .gte('end_date', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active coupons: $e');
    }
  }

  // Create coupon
  Future<Coupon> createCoupon(Coupon coupon) async {
    return await _api.create<Coupon>(
      table: 'coupons',
      data: coupon.toJson(),
      fromJson: Coupon.fromJson,
    );
  }

  // Update coupon
  Future<Coupon> updateCoupon(Coupon coupon) async {
    return await _api.update<Coupon>(
      table: 'coupons',
      id: coupon.id,
      data: coupon.toJson(),
      fromJson: Coupon.fromJson,
    );
  }

  // Delete coupon
  Future<void> deleteCoupon(String id) async {
    await _api.delete(table: 'coupons', id: id);
  }

  // Activate/Deactivate coupon
  Future<Coupon> toggleCouponStatus(String id, bool isActive) async {
    return await _api.update<Coupon>(
      table: 'coupons',
      id: id,
      data: {'is_active': isActive},
      fromJson: Coupon.fromJson,
    );
  }

  // Get coupon performance analytics
  Future<List<Map<String, dynamic>>> getCouponPerformance(String restaurantId) async {
    try {
      final response = await _api.client
          .from('coupons')
          .select('''
            id,
            title,
            created_at,
            usage_count,
            views:coupon_views(count),
            redemptions:coupon_redemptions(count),
            favorites:coupon_favorites(count)
          ''')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get coupon performance: $e');
    }
  }

  // Get customer insights for restaurant
  Future<List<Map<String, dynamic>>> getCustomerInsights(String restaurantId) async {
    try {
      final response = await _api.client
          .from('coupon_redemptions')
          .select('''
            user_id,
            users!inner(display_name, photo_url),
            created_at,
            coupon_id,
            coupons!inner(categories)
          ''')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get customer insights: $e');
    }
  }

  // Upload coupon images
  Future<List<String>> uploadCouponImages(String couponId, List<dynamic> files) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final path = 'coupons/$couponId/image_${i}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _api.uploadFile(
        bucket: 'coupon-media',
        path: path,
        file: files[i],
      );
      urls.add(url);
    }
    return urls;
  }

  // Generate QR code data for coupon
  String generateQRCodeData(Coupon coupon) {
    return 'coupon:${coupon.id}:${coupon.code ?? ''}';
  }

  // Validate coupon redemption
  Future<bool> validateCouponRedemption(String couponId, String userId) async {
    try {
      final coupon = await getCouponById(couponId);
      if (coupon == null) return false;

      // Check if coupon is valid
      if (!coupon.isValid) return false;

      // Check usage limits
      if (coupon.isUsageLimitReached) return false;

      // Check per-user limit
      if (coupon.perUserLimit != null) {
        final userRedemptions = await _api.client
            .from('coupon_redemptions')
            .select('id')
            .eq('coupon_id', couponId)
            .eq('user_id', userId)
            .eq('status', 'completed');

        if ((userRedemptions as List).length >= coupon.perUserLimit!) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Redeem coupon
  Future<CouponRedemption> redeemCoupon({
    required String couponId,
    required String userId,
    required String restaurantId,
    String? redemptionCode,
  }) async {
    try {
      // Validate redemption
      final isValid = await validateCouponRedemption(couponId, userId);
      if (!isValid) {
        throw Exception('Coupon redemption is not valid');
      }

      // Create redemption record
      final redemption = CouponRedemption(
        id: '',
        couponId: couponId,
        userId: userId,
        restaurantId: restaurantId,
        redemptionCode: redemptionCode ?? DateTime.now().millisecondsSinceEpoch.toString(),
        status: 'completed',
        redeemedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final createdRedemption = await _api.create<CouponRedemption>(
        table: 'coupon_redemptions',
        data: redemption.toJson(),
        fromJson: CouponRedemption.fromJson,
      );

      // Update coupon usage count
      await _api.client
          .from('coupons')
          .update({'usage_count': _api.client.rpc('increment_usage_count', params: {'coupon_id': couponId})})
          .eq('id', couponId);

      return createdRedemption;
    } catch (e) {
      throw Exception('Failed to redeem coupon: $e');
    }
  }

  // Search coupons
  Future<List<Coupon>> searchCoupons(String query) async {
    try {
      final response = await _api.client
          .from('coupons')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search coupons: $e');
    }
  }
}