import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/constant.dart';

import '../models/order_model.dart';
import '../services/token_storage.dart';


class ApiService {
  Future<http.Response> getAuthenticatedRequest(String endpoint) async {
    final token = await TokenStorage.getToken();

    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(
      AppConstants.apiTimeout,
      onTimeout: () {
        throw TimeoutException('Connection timed out. Server is taking too long to respond.');
      },
    );
  }

  Future<http.Response> postAuthenticatedRequest(String endpoint, dynamic body) async {
    final token = await TokenStorage.getToken();

    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(
      AppConstants.apiTimeout,
      onTimeout: () {
        throw TimeoutException('Connection timed out. Server is taking too long to respond.');
      },
    );
  }

  Future<http.Response> logout() async {
    final token = await TokenStorage.getToken();
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}logout'), // Matches {{baseURL}}logout
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(
      AppConstants.apiTimeout,
      onTimeout: () {
        throw TimeoutException('Connection timed out. Server is taking too long to respond.');
      },
    );
  }


  Future<OrderResponse> fetchOrders() async {
    try {
      // Update endpoint to match the successful Postman request
      const endpoint = 'order?limit=100&include=tables,user,items&sort=-created_at';

     // debugPrint('📡 Fetching orders: $baseUrl$endpoint');
      final response = await getAuthenticatedRequest(endpoint);

      debugPrint('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Orders fetched successfully');
        final jsonData = json.decode(response.body);

        // Debug data structure
        debugPrint('🔍 Response data structure: ${jsonData.keys}');

        return OrderResponse.fromJson(jsonData);
      } else {
        // Detailed error information
        debugPrint('❌ Error fetching orders: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('🔥 Exception in fetchOrders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }


//new




  Future<http.Response> updateOrderStatus(int id, String newStatus) async {
    final endpoint = 'order/$id/update-status';
    print('Updating to status: $newStatus'); // Debug print
    return await postAuthenticatedRequest(endpoint, {'status': newStatus});
  }

}