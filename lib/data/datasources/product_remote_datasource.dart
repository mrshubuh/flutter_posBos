import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/models/request/product_request_model.dart';
import 'package:flutter_pos/data/models/response/add_product_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pos/data/models/response/product_response_model.dart';

import '../models/response/category_response_model.dart';
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProducts() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/products'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Products loaded successfully: ${response.body}');
      return right(ProductResponseModel.fromJson(response.body));
    } else {
      debugPrint('Failed to load products: ${response.body}');
      return left(response.body);
    }
  }

  Future<Either<String, AddProductResponseModel>> addProduct(
      ProductRequestModel productRequestModel) async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final Map<String, String> headers = {
        'Authorization': 'Bearer ${authData.token}',
      };
      
      var request = http.MultipartRequest(
          'POST', Uri.parse('${Variables.baseUrl}/api/products'));
          
      // Convert all values to String and add to fields
      final fields = productRequestModel.toMap();
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add image if provided
      if (productRequestModel.image != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', productRequestModel.image!.path));
      }
      
      request.headers.addAll(headers);

      final response = await request.send();
      final String body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        debugPrint('Product added successfully: $body');
        return right(AddProductResponseModel.fromJson(body));
      } else {
        debugPrint('Failed to add product: $body');
        return left(body);
      }
    } catch (e) {
      debugPrint('Failed to add product: $e');
      return left(e.toString());
    }
  }

  //get categories
  Future<Either<String, CategoryResponseModel>> getCategories() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/categories'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Categories loaded successfully: ${response.body}');
      return right(CategoryResponseModel.fromJson(response.body));
    } else {
      debugPrint('Failed to load categories: ${response.body}');
      return left(response.body);
    }
  }
}
