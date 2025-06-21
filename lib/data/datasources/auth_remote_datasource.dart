import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/login'),
        body: {
          'email': email,
          'password': password,
        },
      );
      
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        // Use fromMap since we already have a decoded map
        return right(AuthResponseModel.fromMap(responseData));
      } else {
        return left(responseData['message']?.toString() ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return left('An error occurred: $e');
    }
  }

  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/logout'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    if (response.statusCode == 200) {
      return right(response.body);
    } else {
      return left(response.body);
    }
  }
}
