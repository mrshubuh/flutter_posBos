
import 'package:image_picker/image_picker.dart';

class ProductRequestModel {
  final String name;
  final String? description;
  final int price;
  final int stock;
  final int categoryId;
  final String sku;
  final String unitOfMeasure;
  final String? expiredDate;
  final bool isBestSeller;
  final bool isReady;
  final XFile? image;

  ProductRequestModel({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.sku = '',
    this.unitOfMeasure = 'pcs',
    this.expiredDate,
    this.isBestSeller = false,
    this.isReady = false,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description ?? '',
      'price': price.toString(),
      'stock': stock.toString(),
      'category_id': categoryId.toString(),
      'sku': sku,
      'unit_of_measure': unitOfMeasure,
      'expired_date': expiredDate,
      'is_best_seller': isBestSeller ? '1' : '0',
      'is_ready': isReady ? '1' : '0',
    };
  }
}
