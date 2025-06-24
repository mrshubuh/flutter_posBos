import 'dart:convert';

class TaxResponseModel {
  final int id;
  final String name;
  final double rate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  TaxResponseModel({
    required this.id,
    required this.name,
    required this.rate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TaxResponseModel.fromMap(Map<String, dynamic> map) {
    return TaxResponseModel(
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

  static List<TaxResponseModel> fromList(List<dynamic> list) =>
      list.map((e) => TaxResponseModel.fromMap(e)).toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'rate': rate,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
  factory TaxResponseModel.fromJson(String source) =>
      TaxResponseModel.fromMap(json.decode(source));
}
