import 'package:equatable/equatable.dart';

class RestaurantAnalytics extends Equatable {
  final int totalCoupons;
  final int activeCoupons;
  final int totalRedemptions;
  final int totalViews;
  final int totalFavorites;
  final int uniqueCustomers;
  final double? conversionRate;
  final double? averageViewsPerCoupon;
  final double? averageRedemptionsPerCoupon;

  const RestaurantAnalytics({
    required this.totalCoupons,
    required this.activeCoupons,
    required this.totalRedemptions,
    required this.totalViews,
    required this.totalFavorites,
    required this.uniqueCustomers,
    this.conversionRate,
    this.averageViewsPerCoupon,
    this.averageRedemptionsPerCoupon,
  });

  factory RestaurantAnalytics.fromJson(Map<String, dynamic> json) {
    return RestaurantAnalytics(
      totalCoupons: json['total_coupons'] as int? ?? 0,
      activeCoupons: json['active_coupons'] as int? ?? 0,
      totalRedemptions: json['total_redemptions'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      totalFavorites: json['total_favorites'] as int? ?? 0,
      uniqueCustomers: json['unique_customers'] as int? ?? 0,
      conversionRate: json['conversion_rate'] != null 
          ? (json['conversion_rate'] as num).toDouble() 
          : null,
      averageViewsPerCoupon: json['average_views_per_coupon'] != null 
          ? (json['average_views_per_coupon'] as num).toDouble() 
          : null,
      averageRedemptionsPerCoupon: json['average_redemptions_per_coupon'] != null 
          ? (json['average_redemptions_per_coupon'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_coupons': totalCoupons,
      'active_coupons': activeCoupons,
      'total_redemptions': totalRedemptions,
      'total_views': totalViews,
      'total_favorites': totalFavorites,
      'unique_customers': uniqueCustomers,
      'conversion_rate': conversionRate,
      'average_views_per_coupon': averageViewsPerCoupon,
      'average_redemptions_per_coupon': averageRedemptionsPerCoupon,
    };
  }

  RestaurantAnalytics copyWith({
    int? totalCoupons,
    int? activeCoupons,
    int? totalRedemptions,
    int? totalViews,
    int? totalFavorites,
    int? uniqueCustomers,
    double? conversionRate,
    double? averageViewsPerCoupon,
    double? averageRedemptionsPerCoupon,
  }) {
    return RestaurantAnalytics(
      totalCoupons: totalCoupons ?? this.totalCoupons,
      activeCoupons: activeCoupons ?? this.activeCoupons,
      totalRedemptions: totalRedemptions ?? this.totalRedemptions,
      totalViews: totalViews ?? this.totalViews,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      uniqueCustomers: uniqueCustomers ?? this.uniqueCustomers,
      conversionRate: conversionRate ?? this.conversionRate,
      averageViewsPerCoupon: averageViewsPerCoupon ?? this.averageViewsPerCoupon,
      averageRedemptionsPerCoupon: averageRedemptionsPerCoupon ?? this.averageRedemptionsPerCoupon,
    );
  }

  @override
  List<Object?> get props => [
        totalCoupons,
        activeCoupons,
        totalRedemptions,
        totalViews,
        totalFavorites,
        uniqueCustomers,
        conversionRate,
        averageViewsPerCoupon,
        averageRedemptionsPerCoupon,
      ];
}

class CouponPerformance extends Equatable {
  final String couponId;
  final String title;
  final int views;
  final int redemptions;
  final int favorites;
  final double conversionRate;
  final DateTime createdAt;

  const CouponPerformance({
    required this.couponId,
    required this.title,
    required this.views,
    required this.redemptions,
    required this.favorites,
    required this.conversionRate,
    required this.createdAt,
  });

  factory CouponPerformance.fromJson(Map<String, dynamic> json) {
    return CouponPerformance(
      couponId: json['coupon_id'] as String,
      title: json['title'] as String,
      views: json['views'] as int? ?? 0,
      redemptions: json['redemptions'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'title': title,
      'views': views,
      'redemptions': redemptions,
      'favorites': favorites,
      'conversion_rate': conversionRate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        couponId,
        title,
        views,
        redemptions,
        favorites,
        conversionRate,
        createdAt,
      ];
}

class CustomerInsight extends Equatable {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int totalRedemptions;
  final int totalFavorites;
  final DateTime lastActivity;
  final List<String> favoriteCategories;

  const CustomerInsight({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.totalRedemptions,
    required this.totalFavorites,
    required this.lastActivity,
    this.favoriteCategories = const [],
  });

  factory CustomerInsight.fromJson(Map<String, dynamic> json) {
    return CustomerInsight(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      totalRedemptions: json['total_redemptions'] as int? ?? 0,
      totalFavorites: json['total_favorites'] as int? ?? 0,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      favoriteCategories: json['favorite_categories'] != null
          ? List<String>.from(json['favorite_categories'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'photo_url': photoUrl,
      'total_redemptions': totalRedemptions,
      'total_favorites': totalFavorites,
      'last_activity': lastActivity.toIso8601String(),
      'favorite_categories': favoriteCategories,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        totalRedemptions,
        totalFavorites,
        lastActivity,
        favoriteCategories,
      ];
}
