class AppConstants {
  // App Info
  static const String appName = 'Coupon Manager';
  static const String appVersion = '1.0.0';

  // API & Storage
  static const String supabaseUrl = 'https://ixgvejltppxpnjkkucgs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4Z3Zlamx0cHB4cG5qa2t1Y2dzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3OTU3NDksImV4cCI6MjA3NTM3MTc0OX0.v4anTQaYBB8_QQ2YfCn1zjCCoD30-1iF4C60XnL2Cec';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String restaurantMediaBucket = 'restaurant-media';
  static const String couponMediaBucket = 'coupon-media';

  // Database Tables
  static const String usersTable = 'users';
  static const String restaurantsTable = 'restaurants';
  static const String couponsTable = 'coupons';
  static const String redemptionsTable = 'coupon_redemptions';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleRestaurant = 'restaurant';
  static const String roleAdmin = 'admin';

  // Coupon Status
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusPaused = 'paused';
  static const String statusExpired = 'expired';
  static const String statusDeleted = 'deleted';

  // Restaurant Status
  static const String restaurantStatusPending = 'pending';
  static const String restaurantStatusActive = 'active';
  static const String restaurantStatusInactive = 'inactive';
  static const String restaurantStatusSuspended = 'suspended';

  // Redemption Status
  static const String redemptionPending = 'pending';
  static const String redemptionCompleted = 'completed';
  static const String redemptionCancelled = 'cancelled';
  static const String redemptionFailed = 'failed';

  // Discount Types
  static const String discountPercentage = 'percentage';
  static const String discountFixedAmount = 'fixed_amount';
  static const String discountBogo = 'buy_one_get_one';

  // Pagination
  static const int defaultPageSize = 20;
  static const int featuredCouponsLimit = 10;
  static const int nearbyCouponsLimit = 20;

  // Cache Keys
  static const String cacheUserProfile = 'user_profile';
  static const String cacheFeaturedCoupons = 'featured_coupons';
  static const String cacheNearbyRestaurants = 'nearby_restaurants';
  static const String cacheCategories = 'categories';

  // Cache Duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(hours: 24);

  // Location
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  static const double defaultSearchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km

  // File Upload
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxBioLength = 200;

  // UI
  static const double bottomNavHeight = 60.0;
  static const double appBarHeight = 56.0;
  static const double fabSize = 56.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorNotFound = 'The requested item was not found.';

  // Success Messages
  static const String successSaved = 'Changes saved successfully!';
  static const String successDeleted = 'Item deleted successfully!';
  static const String successCreated = 'Item created successfully!';
  static const String successUpdated = 'Item updated successfully!';

  // Routes
  static const String routeSplash = '/splash';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
}
