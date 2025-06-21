import 'dart:convert';


class ProductResponseModel {
  final bool success;
  final String message;
  final List<Product> data;

  ProductResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductResponseModel.fromJson(String str) =>
      ProductResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductResponseModel.fromMap(Map<String, dynamic> json) =>
      ProductResponseModel(
        success: json["success"],
        message: json["message"],
        data: List<Product>.from(json["data"].map((x) => Product.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Product {
  final int? id;
  final int? productId;
  final String name;
  final String? description;
  final int price;
  final int stock;
  final int categoryId;
  final String sku;
  final String unitOfMeasure;
  final DateTime? expiredDate;
  final String image;
  final bool isBestSeller;
  final bool isReady;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.sku,
    required this.unitOfMeasure,
    this.expiredDate,
    required this.image,
    this.isBestSeller = false,
    this.isReady = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        price: json["price"] is String ? int.tryParse(json["price"].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : (json["price"] ?? 0),
        stock: json["stock"] ?? 0,
        categoryId: json["category_id"] != null
            ? (json["category_id"] is String
                ? int.tryParse(json["category_id"]) ?? 0
                : json["category_id"])
            : 0,
        sku: json["sku"] ?? '',
        unitOfMeasure: json["unit_of_measure"] ?? 'pcs',
        expiredDate: json["expired_date"] != null ? DateTime.tryParse(json["expired_date"]) : null,
        image: json["image"] ?? 'products/default-product.jpg',
        isBestSeller: json["is_best_seller"] == true || json["is_best_seller"] == 1,
        isReady: json["isReady"] ?? false,

        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),

        // createdAt: json["created_at"] != null
        //     ? DateTime.parse(json["created_at"])
        //     : null,
        // updatedAt: json["updated_at"] != null
        //     ? DateTime.parse(json["updated_at"])
        //     : null,
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "price": price,
        "stock": stock,
        "category_id": categoryId,
        "sku": sku,
        "unit_of_measure": unitOfMeasure,
        "expired_date": expiredDate?.toIso8601String(),
        "image": image,
        "is_best_seller": isBestSeller,
        "isReady": isReady,
        "product_id": productId,
      };
  Map<String, dynamic> toLocalMap() => {
        "name": name,
        "price": price,
        "stock": stock,
        "category_id": categoryId,
        "sku": sku,
        "unit_of_measure": unitOfMeasure,
        "expired_date": expiredDate?.toIso8601String(),
        "image": image,
        "is_best_seller": isBestSeller ? 1 : 0,
        "is_ready": isReady ? 1 : 0,
        "product_id": id,
      };

  Product copyWith({
    int? id,
    int? productId,
    String? name,
    String? description,
    int? price,
    int? stock,
    int? categoryId,
    String? sku,
    String? unitOfMeasure,
    DateTime? expiredDate,
    String? image,
    bool? isBestSeller,
    bool? isReady,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      expiredDate: expiredDate ?? this.expiredDate,
      image: image ?? this.image,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isReady: isReady ?? this.isReady,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.stock == stock &&
        other.categoryId == categoryId &&
        other.sku == sku &&
        other.unitOfMeasure == unitOfMeasure &&
        other.expiredDate == expiredDate &&
        other.image == image &&
        other.isBestSeller == isBestSeller &&
        other.isReady == isReady &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        stock.hashCode ^
        categoryId.hashCode ^
        sku.hashCode ^
        unitOfMeasure.hashCode ^
        expiredDate.hashCode ^
        image.hashCode ^
        isBestSeller.hashCode ^
        isReady.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
