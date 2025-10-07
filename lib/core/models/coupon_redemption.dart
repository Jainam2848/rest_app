import 'package:equatable/equatable.dart';

class CouponRedemption extends Equatable {
  final String id;
  final String couponId;
  final String userId;
  final String restaurantId;
  final String? qrCode;
  final double? discountAmount;
  final double? originalAmount;
  final double? finalAmount;
  final String status; // pending, completed, cancelled, failed
  final DateTime redeemedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final Map<String, dynamic>? metadata;

  const CouponRedemption({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.restaurantId,
    this.qrCode,
    this.discountAmount,
    this.originalAmount,
    this.finalAmount,
    this.status = 'pending',
    required this.redeemedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.metadata,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  factory CouponRedemption.fromJson(Map<String, dynamic> json) {
    return CouponRedemption(
      id: json['id'] as String,
      couponId: json['coupon_id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      qrCode: json['qr_code'] as String?,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      originalAmount: json['original_amount'] != null
          ? (json['original_amount'] as num).toDouble()
          : null,
      finalAmount: json['final_amount'] != null
          ? (json['final_amount'] as num).toDouble()
          : null,
      status: json['status'] as String? ?? 'pending',
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verifiedBy: json['verified_by'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupon_id': couponId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'qr_code': qrCode,
      'discount_amount': discountAmount,
      'original_amount': originalAmount,
      'final_amount': finalAmount,
      'status': status,
      'redeemed_at': redeemedAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'metadata': metadata,
    };
  }

  CouponRedemption copyWith({
    String? id,
    String? couponId,
    String? userId,
    String? restaurantId,
    String? qrCode,
    double? discountAmount,
    double? originalAmount,
    double? finalAmount,
    String? status,
    DateTime? redeemedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    Map<String, dynamic>? metadata,
  }) {
    return CouponRedemption(
      id: id ?? this.id,
      couponId: couponId ?? this.couponId,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      qrCode: qrCode ?? this.qrCode,
      discountAmount: discountAmount ?? this.discountAmount,
      originalAmount: originalAmount ?? this.originalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        couponId,
        userId,
        restaurantId,
        qrCode,
        discountAmount,
        originalAmount,
        finalAmount,
        status,
        redeemedAt,
        verifiedAt,
        verifiedBy,
        metadata,
      ];
}
