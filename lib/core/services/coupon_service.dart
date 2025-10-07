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
      throw ApiException('Failed to fetch active coupons: $e');
    }
  }

  // Create coupon
  Future<Coupon> createCoupon(Coupon coupon) async {
    return await _api.insert<Coupon>(
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
    await _api.delete(
      table: 'coupons',
      id: id,
    );
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
      throw ApiException('Failed to search coupons: $e');
    }
  }

  // Redeem coupon
  Future<CouponRedemption> redeemCoupon({
    required String couponId,
    required String userId,
    required String restaurantId,
    String? qrCode,
    double? originalAmount,
    double? discountAmount,
    double? finalAmount,
  }) async {
    final redemption = {
      'coupon_id': couponId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'qr_code': qrCode,
      'original_amount': originalAmount,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'status': 'pending',
      'redeemed_at': DateTime.now().toIso8601String(),
    };

    return await _api.insert<CouponRedemption>(
      table: 'coupon_redemptions',
      data: redemption,
      fromJson: CouponRedemption.fromJson,
    );
  }

  // Verify redemption
  Future<CouponRedemption> verifyRedemption({
    required String redemptionId,
    required String verifiedBy,
  }) async {
    final data = {
      'status': 'completed',
      'verified_at': DateTime.now().toIso8601String(),
      'verified_by': verifiedBy,
    };

    return await _api.update<CouponRedemption>(
      table: 'coupon_redemptions',
      id: redemptionId,
      data: data,
      fromJson: CouponRedemption.fromJson,
    );
  }

  // Get redemption history for user
  Future<List<CouponRedemption>> getUserRedemptions(String userId) async {
    return await _api.query<CouponRedemption>(
      table: 'coupon_redemptions',
      fromJson: CouponRedemption.fromJson,
      orderBy: 'redeemed_at',
      ascending: false,
      filters: {'user_id': userId},
    );
  }

  // Get redemption history for restaurant
  Future<List<CouponRedemption>> getRestaurantRedemptions(
    String restaurantId,
  ) async {
    return await _api.query<CouponRedemption>(
      table: 'coupon_redemptions',
      fromJson: CouponRedemption.fromJson,
      orderBy: 'redeemed_at',
      ascending: false,
      filters: {'restaurant_id': restaurantId},
    );
  }

  // Upload coupon image
  Future<String> uploadCouponImage(String couponId, dynamic file) async {
    final path = 'coupons/$couponId/image_${DateTime.now().millisecondsSinceEpoch}';
    return await _api.uploadFile(
      bucket: 'coupon-media',
      path: path,
      file: file,
    );
  }

  // Upload coupon video
  Future<String> uploadCouponVideo(String couponId, dynamic file) async {
    final path = 'coupons/$couponId/video_${DateTime.now().millisecondsSinceEpoch}';
    return await _api.uploadFile(
      bucket: 'coupon-media',
      path: path,
      file: file,
    );
  }
}
