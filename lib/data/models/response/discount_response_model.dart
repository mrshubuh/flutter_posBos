import 'dart:convert';

class DiscountResponseModel {
  final int id;
  final String name;
  final String description;
  final String type; // percentage, fixed, buy_x_get_y, etc.
  final double value;
  final String status; // active, inactive
  final int minQuantity;
  final int maxQuantity;
  final double minAmount;
  final String applyTo; // all, specific_products
  final String customerType; // all, member, wholesale, retail
  final List<int> validDays; // 1=Senin, 7=Minggu
  final DateTime? startAt;
  final DateTime? expiredAt;
  final String? startTime;
  final String? endTime;
  final bool combinable;
  final int? usageLimit;
  final int usageCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiscountResponseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.status,
    required this.minQuantity,
    required this.maxQuantity,
    required this.minAmount,
    required this.applyTo,
    required this.customerType,
    required this.validDays,
    this.startAt,
    this.expiredAt,
    this.startTime,
    this.endTime,
    this.combinable = false,
    this.usageLimit,
    this.usageCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DiscountResponseModel.fromMap(Map<String, dynamic> map) {
    List<int> validDaysParsed = [];
    final validDaysRaw = map['valid_days'];
    if (validDaysRaw is String) {
      validDaysParsed = validDaysRaw
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
    } else if (validDaysRaw is List) {
      validDaysParsed =
          validDaysRaw.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }
    return DiscountResponseModel(
      id: int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'percentage',
      value: (map['value'] is String)
          ? double.tryParse(map['value']) ?? 0.0
          : (map['value'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'inactive',
      minQuantity: int.tryParse(map['min_quantity']?.toString() ?? '') ?? 0,
      maxQuantity: int.tryParse(map['max_quantity']?.toString() ?? '') ?? 0,
      minAmount: (map['min_amount'] is String)
          ? double.tryParse(map['min_amount']) ?? 0.0
          : (map['min_amount'] as num?)?.toDouble() ?? 0.0,
      applyTo: map['apply_to'] as String? ?? 'all',
      customerType: map['customer_type'] as String? ?? 'all',
      validDays: validDaysParsed,
      startAt:
          map['start_at'] != null ? DateTime.tryParse(map['start_at']) : null,
      expiredAt: map['expired_at'] != null
          ? DateTime.tryParse(map['expired_at'])
          : null,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      combinable: map['combinable'] == 1 ||
          map['combinable'] == true ||
          map['combinable'] == '1',
      usageLimit: map['usage_limit'] != null
          ? int.tryParse(map['usage_limit'].toString())
          : null,
      usageCount: int.tryParse(map['usage_count']?.toString() ?? '') ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  factory DiscountResponseModel.fromJson(String source) =>
      DiscountResponseModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'value': value,
        'status': status,
        'min_quantity': minQuantity,
        'max_quantity': maxQuantity,
        'min_amount': minAmount,
        'apply_to': applyTo,
        'customer_type': customerType,
        'valid_days': validDays,
        'start_date': startAt?.toIso8601String(),
        'expired_date': expiredAt?.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'combinable': combinable ? 1 : 0,
        'usage_limit': usageLimit,
        'usage_count': usageCount,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}
