import 'dart:convert';

class ServiceChargeResponseModel {
  final int id;
  final String name;
  final double rate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  ServiceChargeResponseModel({
    required this.id,
    required this.name,
    required this.rate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ServiceChargeResponseModel.fromMap(Map<String, dynamic> map) {
    return ServiceChargeResponseModel(
      id: map['id'] as int,
      name: map['name'] as String,
      rate: (map['rate'] is String)
          ? double.tryParse(map['rate']) ?? 0.0
          : (map['rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'])
          : null,
    );
  }

  static List<ServiceChargeResponseModel> fromList(List<dynamic> list) =>
      list.map((e) => ServiceChargeResponseModel.fromMap(e)).toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'rate': rate,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
  factory ServiceChargeResponseModel.fromJson(String source) =>
      ServiceChargeResponseModel.fromMap(json.decode(source));
}
