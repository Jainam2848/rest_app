import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant.dart';
import '../models/coupon.dart';
import '../models/analytics.dart';
import '../services/restaurant_service.dart';
import '../services/coupon_service.dart';
import 'auth_provider.dart';

// Restaurant Service Provider
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

// Coupon Service Provider
final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService();
});

// Current Restaurant Provider
final currentRestaurantProvider = FutureProvider<Restaurant?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final restaurantService = ref.read(restaurantServiceProvider);
  
  return userAsync.when(
    data: (user) async {
      if (user == null) return null;
      
      try {
        final restaurants = await restaurantService.getRestaurantsByOwner(user.id);
        return restaurants.isNotEmpty ? restaurants.first : null;
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Restaurant Analytics Provider
final restaurantAnalyticsProvider = FutureProvider<RestaurantAnalytics?>((ref) async {
  final restaurantAsync = ref.watch(currentRestaurantProvider);
  final restaurantService = ref.read(restaurantServiceProvider);
  
  return restaurantAsync.when(
    data: (restaurant) async {
      if (restaurant == null) return null;
      
      try {
        final analyticsData = await restaurantService.getRestaurantAnalytics(restaurant.id);
        return RestaurantAnalytics.fromJson(analyticsData);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Restaurant Coupons Provider
final restaurantCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final restaurantAsync = ref.watch(currentRestaurantProvider);
  final couponService = ref.read(couponServiceProvider);
  
  return restaurantAsync.when(
    data: (restaurant) async {
      if (restaurant == null) return [];
      
      try {
        return await couponService.getCoupons(restaurantId: restaurant.id);
      } catch (e) {
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Active Coupons Provider
final activeCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final restaurantAsync = ref.watch(currentRestaurantProvider);
  final couponService = ref.read(couponServiceProvider);
  
  return restaurantAsync.when(
    data: (restaurant) async {
      if (restaurant == null) return [];
      
      try {
        return await couponService.getActiveCoupons(restaurant.id);
      } catch (e) {
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Coupon Performance Provider
final couponPerformanceProvider = FutureProvider<List<CouponPerformance>>((ref) async {
  final restaurantAsync = ref.watch(currentRestaurantProvider);
  final couponService = ref.read(couponServiceProvider);
  
  return restaurantAsync.when(
    data: (restaurant) async {
      if (restaurant == null) return [];
      
      try {
        final performanceData = await couponService.getCouponPerformance(restaurant.id);
        return performanceData.map((data) => CouponPerformance.fromJson(data)).toList();
      } catch (e) {
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Customer Insights Provider
final customerInsightsProvider = FutureProvider<List<CustomerInsight>>((ref) async {
  final restaurantAsync = ref.watch(currentRestaurantProvider);
  final couponService = ref.read(couponServiceProvider);
  
  return restaurantAsync.when(
    data: (restaurant) async {
      if (restaurant == null) return [];
      
      try {
        final insightsData = await couponService.getCustomerInsights(restaurant.id);
        return insightsData.map((data) => CustomerInsight.fromJson(data)).toList();
      } catch (e) {
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Coupon Creation State Provider
final couponCreationProvider = StateNotifierProvider<CouponCreationNotifier, CouponCreationState>((ref) {
  return CouponCreationNotifier(ref.read(couponServiceProvider));
});

class CouponCreationState {
  final bool isLoading;
  final String? error;
  final Coupon? createdCoupon;

  const CouponCreationState({
    this.isLoading = false,
    this.error,
    this.createdCoupon,
  });

  CouponCreationState copyWith({
    bool? isLoading,
    String? error,
    Coupon? createdCoupon,
  }) {
    return CouponCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      createdCoupon: createdCoupon ?? this.createdCoupon,
    );
  }
}

class CouponCreationNotifier extends StateNotifier<CouponCreationState> {
  final CouponService _couponService;

  CouponCreationNotifier(this._couponService) : super(const CouponCreationState());

  Future<void> createCoupon(Coupon coupon) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final createdCoupon = await _couponService.createCoupon(coupon);
      state = state.copyWith(
        isLoading: false,
        createdCoupon: createdCoupon,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateCoupon(Coupon coupon) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedCoupon = await _couponService.updateCoupon(coupon);
      state = state.copyWith(
        isLoading: false,
        createdCoupon: updatedCoupon,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CouponCreationState();
  }
}

// Restaurant Creation State Provider
final restaurantCreationProvider = StateNotifierProvider<RestaurantCreationNotifier, RestaurantCreationState>((ref) {
  return RestaurantCreationNotifier(ref.read(restaurantServiceProvider));
});

class RestaurantCreationState {
  final bool isLoading;
  final String? error;
  final Restaurant? createdRestaurant;

  const RestaurantCreationState({
    this.isLoading = false,
    this.error,
    this.createdRestaurant,
  });

  RestaurantCreationState copyWith({
    bool? isLoading,
    String? error,
    Restaurant? createdRestaurant,
  }) {
    return RestaurantCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      createdRestaurant: createdRestaurant ?? this.createdRestaurant,
    );
  }
}

class RestaurantCreationNotifier extends StateNotifier<RestaurantCreationState> {
  final RestaurantService _restaurantService;

  RestaurantCreationNotifier(this._restaurantService) : super(const RestaurantCreationState());

  Future<void> createRestaurant(Restaurant restaurant) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final createdRestaurant = await _restaurantService.createRestaurant(restaurant);
      state = state.copyWith(
        isLoading: false,
        createdRestaurant: createdRestaurant,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedRestaurant = await _restaurantService.updateRestaurant(restaurant);
      state = state.copyWith(
        isLoading: false,
        createdRestaurant: updatedRestaurant,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const RestaurantCreationState();
  }
}
