enum UserRole {
  customer,
  restaurant,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.restaurant:
        return 'Restaurant';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'restaurant':
        return UserRole.restaurant;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}
