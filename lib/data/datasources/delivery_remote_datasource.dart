import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/data/models/request/delivery_request_model.dart';

class DeliveryRemoteDatasource {
  Future<Map<String, dynamic>> createDelivery(
      DeliveryRequestModel delivery) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/deliveries'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
      body: json.encode(delivery.toMap()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      debugPrint('Failed to create delivery: ${response.body}');
      throw Exception('Failed to create delivery: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveries() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/deliveries'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['data']);
    } else {
      debugPrint('Failed to get delivery: ${response.body}');
      throw Exception('Failed to load deliveries');
    }
  }

  Future<Map<String, dynamic>> getDeliveryById(int id) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/deliveries/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      debugPrint('Failed to fetch deliver yby id: ${response.body}');
      throw Exception('Failed to load delivery');
    }
  }
}
