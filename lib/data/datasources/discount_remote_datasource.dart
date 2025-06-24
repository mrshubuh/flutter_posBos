import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/data/models/response/discount_response_model.dart';

class DiscountRemoteDatasource {
  Future<List<DiscountResponseModel>> getDiscounts() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/discounts'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Discounts loaded successfully: ${response.body}');
      final jsonData = json.decode(response.body);
      final List<dynamic> discounts = jsonData['data'];
      return discounts
          .map((json) => DiscountResponseModel.fromMap(json))
          .toList();
    } else {
      debugPrint('Failed to load discounts: ${response.body}');
      throw Exception('Failed to load discounts');
    }
  }

  Future<List<DiscountResponseModel>> getTodayDiscounts() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/discounts/filter/today'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Today discounts loaded successfully: ${response.body}');
      final jsonData = json.decode(response.body);
      final List<dynamic> discounts = jsonData['data'];
      return discounts
          .map((json) => DiscountResponseModel.fromMap(json))
          .toList();
    } else {
      debugPrint('error fetch today discounts: ${response.body}');
      throw Exception('Failed to load today discounts');
    }
  }

  Future<DiscountResponseModel> getDiscountById(int id) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/discounts/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DiscountResponseModel.fromMap(jsonData['data']);
    } else {
      throw Exception('Failed to load discount');
    }
  }
}
