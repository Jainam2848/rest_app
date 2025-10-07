import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String? code;
  final String discountType; // percentage, fixed_amount, buy_one_get_one
  final double? discountValue;
  final double? minPurchase;
  final double? maxDiscount;
  final List<String>? imageUrls;
  final String? videoUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int? usageCount;
  final int? perUserLimit;
  final List<String> categories;
  final String status; // draft, active, paused, expired, deleted
  final bool isActive;
  final bool isFeatured;
  final int? priority;
  final Map<String, dynamic>? terms;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Coupon({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    this.code,
    required this.discountType,
    this.discountValue,
    this.minPurchase,
    this.maxDiscount,
    this.imageUrls,
    this.videoUrl,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usageCount = 0,
    this.perUserLimit,
    this.categories = const [],
    this.status = 'draft',
    this.isActive = false,
    this.isFeatured = false,
    this.priority,
    this.terms,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isValid => !isExpired && !isUpcoming && isActive;
  bool get hasUsageLimit => usageLimit != null && usageLimit! > 0;
  bool get isUsageLimitReached => hasUsageLimit && (usageCount ?? 0) >= usageLimit!;

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      code: json['code'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: json['discount_value'] != null
          ? (json['discount_value'] as num).toDouble()
          : null,
      minPurchase: json['min_purchase'] != null
          ? (json['min_purchase'] as num).toDouble()
          : null,
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null,
      videoUrl: json['video_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      perUserLimit: json['per_user_limit'] as int?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : [],
      status: json['status'] as String? ?? 'draft',
      isActive: json['is_active'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      priority: json['priority'] as int?,
      terms: json['terms'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'title': title,
      'description': description,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'per_user_limit': perUserLimit,
      'categories': categories,
      'status': status,
      'is_active': isActive,
      'is_featured': isFeatured,
      'priority': priority,
      'terms': terms,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Coupon copyWith({
    String? id,
    String? restaurantId,
    String? title,
    String? description,
    String? code,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    List<String>? imageUrls,
    String? videoUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usageCount,
    int? perUserLimit,
    List<String>? categories,
    String? status,
    bool? isActive,
    bool? isFeatured,
    int? priority,
    Map<String, dynamic>? terms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      perUserLimit: perUserLimit ?? this.perUserLimit,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      priority: priority ?? this.priority,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        title,
        description,
        code,
        discountType,
        discountValue,
        minPurchase,
        maxDiscount,
        imageUrls,
        videoUrl,
        startDate,
        endDate,
        usageLimit,
        usageCount,
        perUserLimit,
        categories,
        status,
        isActive,
        isFeatured,
        priority,
        terms,
        createdAt,
        updatedAt,
      ];
}
