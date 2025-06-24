import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import '../models/response/service_charge_response_model.dart';

class ServiceChargeRemoteDatasource {
  Future<List<ServiceChargeResponseModel>> getServiceCharges() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/service-charges'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('Service charges loaded successfully: ${response.body}');
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'] ?? jsonData;
      return ServiceChargeResponseModel.fromList(data);
    } else {
      debugPrint('Failed to load service charges: ${response.body}');
      throw Exception('Failed to load service charges');
    }
  }
}
