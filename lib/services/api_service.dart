


import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';


import '../config/constants.dart';

import '../models/category_model.dart';
import '../models/menu_add_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../services/token_storage.dart';


// class ApiService {
//
//
//   // final StreamController<bool> _orderUpdateController = StreamController<bool>.broadcast();
//   // Stream<bool> get orderUpdateStream => _orderUpdateController.stream;
//
//   Future<http.Response> getAuthenticatedRequest(String endpoint) async {
//     final token = await TokenStorage.getToken();
//
//     return await http.get(
//       Uri.parse('${ApiConfig.baseUrl}$endpoint'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     ).timeout(
//       AppConstants.apiTimeout,
//       onTimeout: () {
//         throw TimeoutException(
//             'Connection timed out. Server is taking too long to respond.');
//       },
//     );
//   }
//
//
//
//   Future<http.Response> postAuthenticatedRequest(String endpoint, dynamic body) async {
//     final token = await TokenStorage.getToken();
//     final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
//
//     print('Making API request to: $url');
//     print('Request Body: ${jsonEncode(body)}');
//
//     final client = http.Client();
//     try {
//       // Create a base request
//       final request = http.Request('POST', url)
//         ..headers.addAll({
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-Auth-Key': ApiConfig.authKey,
//           'X-Requested-With': 'XMLHttpRequest', // Important for API requests
//         })
//         ..body = jsonEncode(body);
//
//       // Send the request and follow redirects manually
//       final streamedResponse = await client.send(request);
//       final response = await http.Response.fromStream(streamedResponse);
//
//       print('Response Status: ${response.statusCode}');
//       print('Response Headers: ${response.headers}');
//
//       // Handle redirects
//       if (response.statusCode == 302) {
//         final location = response.headers['location'];
//         if (location != null && location.contains('ivory-antelope-869726.hostingersite.com')) {
//           // If redirecting to homepage, throw specific error
//           throw Exception('''
// Server redirected to homepage. Possible causes:
// 1. Incorrect API endpoint
// 2. Missing authentication
// 3. Server configuration issue
// Original URL: $url
// Redirect URL: $location''');
//         }
//         // Follow the redirect if it's not to homepage
//         return await http.get(Uri.parse(location!));
//       }
//
//       return response;
//     } catch (e) {
//       print('API Request Error: $e');
//       rethrow;
//     } finally {
//       client.close();
//     }
//   }
//
//
//   Future<http.Response> logout() async {
//     final token = await TokenStorage.getToken();
//     return await http.post(
//       Uri.parse('${ApiConfig.baseUrl}logout'), // Matches {{baseURL}}logout
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     ).timeout(
//       AppConstants.apiTimeout,
//       onTimeout: () {
//         throw TimeoutException('Connection timed out. Server is taking too long to respond.');
//       },
//     );
//   }
//
//
//
//
//
//
//
//   Future<OrderResponse> fetchOrders({int? page, int? limit}) async {
//     final token = await TokenStorage.getToken();
//     print('Token: ${token != null ? 'exists' : 'null'}');
//
//     final queryParams = [
//       'include=tables,user,items',
//       'sort=-created_at',
//       'limit=${limit ?? 1000}'
//     ];
//     if (page != null) queryParams.add('page=$page');
//
//     final url = '${ApiConfig.baseUrl}order?${queryParams.join('&')}';
//     print('Requesting orders from: $url');
//
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}'); // Add this line
//
//     if (response.statusCode == 200) {
//       final responseBody = response.body;
//       if (responseBody.isEmpty) {
//         throw Exception('Empty response body');
//       }
//       return OrderResponse.fromJson(json.decode(responseBody));
//     } else {
//       throw Exception('Failed to load orders: ${response.statusCode}');
//     }
//   }
//
//
//
//   Future<bool> updateOrderStatus(int id, String status) async {
//     try {
//       final response = await postAuthenticatedRequest(
//         'order/$id/update-status',
//         {
//           'status': status,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         throw Exception('Failed to update order status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating order status: $e');
//       return false;
//     }
//   }
//
//
//   // In your ApiService class
//   Stream<List<Order>> getOrdersStream() async* {
//     while (true) {
//       try {
//         final response = await fetchOrders(limit: 1000);
//         yield response.data;
//         await Future.delayed(const Duration(seconds: 5)); // Poll every 5 seconds
//       } catch (e) {
//         print('Error in orders stream: $e');
//         await Future.delayed(const Duration(seconds: 10)); // Retry after 10 seconds on error
//       }
//     }
//   }

class ApiService {
  // Helper method to validate response as JSON
  bool _isValidJsonResponse(http.Response response) {
    if (response.statusCode != 200) return false;

    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains('application/json')) {
      print('Invalid content type: $contentType');
      return false;
    }

    try {
      // Check if the response body starts with valid JSON markers
      final trimmed = response.body.trim();
      if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
        print('Response does not appear to be JSON: ${trimmed.substring(0, min(50, trimmed.length))}...');
        return false;
      }

      // Try to decode to validate
      json.decode(response.body);
      return true;
    } catch (e) {
      print('Failed to parse response as JSON: $e');
      return false;
    }
  }

  int min(int a, int b) => a < b ? a : b;

  Future<http.Response> getAuthenticatedRequest(String endpoint) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing or empty');
    }

    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',  // Force JSON response
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest', // Prevents some redirects
      },
    ).timeout(
      AppConstants.apiTimeout,
      onTimeout: () {
        throw TimeoutException(
            'Connection timed out. Server is taking too long to respond.');
      },
    );
  }

  Future<http.Response> postAuthenticatedRequest(String endpoint, dynamic body) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing or empty');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    print('Making API request to: $url');
    print('Request Body: ${jsonEncode(body)}');

    final client = http.Client();
    try {
      // Create a base request
      final request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',  // Force JSON response
          'Authorization': 'Bearer $token',
          'X-Auth-Key': ApiConfig.authKey,
          'X-Requested-With': 'XMLHttpRequest',
        })
        ..body = jsonEncode(body);

      // Send the request and follow redirects manually
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');

      // Handle redirects
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null && location.contains('ivory-antelope-869726.hostingersite.com')) {
          // If redirecting to homepage, throw authentication error
          throw Exception('Authentication failed: Token may be expired or invalid');
        }
        // Follow the redirect if it's not to homepage
        return await http.get(Uri.parse(location!));
      }

      return response;
    } catch (e) {
      print('API Request Error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<http.Response> logout() async {
    final token = await TokenStorage.getToken();
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(
      AppConstants.apiTimeout,
      onTimeout: () {
        throw TimeoutException('Connection timed out. Server is taking too long to respond.');
      },
    );
  }

  Future<OrderResponse> fetchOrders({int? page, int? limit}) async {
    try {
      final token = await TokenStorage.getToken();
      print('Token: ${token != null ? 'exists' : 'null'}');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      final queryParams = [
        'include=tables,user,items',
        'sort=-created_at',
        'limit=${limit ?? 1000}'
      ];
      if (page != null) queryParams.add('page=$page');

      final url = '${ApiConfig.baseUrl}order?${queryParams.join('&')}';
      print('Requesting orders from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',  // Force JSON response
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest', // Prevents some redirects
        },
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw TimeoutException('Connection timed out. Server is taking too long to respond.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response content-type: ${response.headers['content-type']}');

      // Add debug info - only print first 200 chars to avoid flooding
      final previewLength = response.body.length > 200 ? 200 : response.body.length;
      print('Response preview: ${response.body.substring(0, previewLength)}...');

      // Check for HTML response which indicates a likely redirect to login page
      if (response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.trim().startsWith('<html')) {
        print('Received HTML response instead of JSON - likely an authentication issue');
        throw Exception('Authentication error: Session may have expired');
      }

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response body');
        }

        try {
          return OrderResponse.fromJson(json.decode(responseBody));
        } catch (e) {
          print('JSON parsing error: $e');
          throw Exception('Invalid response format: Unable to parse JSON');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error: Please log in again');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchOrders: $e');
      rethrow;
    }
  }

  // Future<bool> updateOrderStatus(int id, String status) async {
  //   try {
  //     final response = await postAuthenticatedRequest(
  //       'order/$id/update-status',
  //       {
  //         'status': status,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       throw Exception('Failed to update order status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error updating order status: $e');
  //     return false;
  //   }
  // }
  Future<bool> updateOrderStatusWithPayment(
      int id,
      Map<String, dynamic> data
      ) async {
    try {
      // Fix the API endpoint - using update-status instead of complete
      final response = await postAuthenticatedRequest(
        'order/$id/update-status',  // Changed from 'complete' to 'update-status'
        data,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        // Handle validation errors more gracefully
        final errorData = jsonDecode(response.body);
        throw Exception('Validation error: ${errorData['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Failed to complete order: ${response.statusCode}${response.body}');
      }
    } catch (e) {
      debugPrint('Error completing order: $e');
      rethrow; // Rethrow to allow caller to handle or display the error
    }
  }

  // Optional helper method to handle different payment methods with different endpoints
  Future<bool> completeOrderWithPayment(
      int id,
      Map<String, dynamic> data
      ) async {
    try {
      // Determine the correct endpoint based on your API structure
      final endpoint = 'order/$id/update-status';

      final response = await postAuthenticatedRequest(endpoint, data);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty
            ? 'Error: ${response.statusCode} - ${response.body}'
            : 'Error: ${response.statusCode}';
        debugPrint(errorMsg);
        throw Exception('Failed to complete order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error completing order: $e');
      rethrow;
    }
  }

  // Modified orders stream with better error handling
  Stream<List<Order>> getOrdersStream() async* {
    int retryCount = 0;
    const maxRetries = 3;
    const initialRetryDelay = 10; // seconds

    while (true) {
      try {
        final response = await fetchOrders(limit: 1000);
        // Reset retry count on success
        retryCount = 0;
        yield response.data;
        await Future.delayed(const Duration(seconds: 5)); // Poll every 5 seconds
      } catch (e) {
        print('Error in orders stream: $e');

        // Handle authentication errors by notifying client code
        if (e.toString().contains('Authentication error') ||
            e.toString().contains('Authentication failed')) {
          yield []; // Empty list as a signal

          // Emit a special error that can be caught by UI
          // Note: You might need to create a custom Stream implementation for this
          // or handle it in your UI by checking for empty lists

          // Increase backoff time for repeated failures
          retryCount++;
          final delay = retryCount <= maxRetries
              ? initialRetryDelay * retryCount
              : 60; // Cap at 60 seconds

          print('Authentication error. Retry attempt $retryCount in $delay seconds');
          await Future.delayed(Duration(seconds: delay));
        } else {
          // For non-auth errors, retry quicker
          await Future.delayed(const Duration(seconds: 10));
        }
      }
    }
  }

  Future<bool> addCategory(String categoryName) async {
    try {
      final response = await postAuthenticatedRequest(
        'category',
        {
          'name': categoryName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }


  Future<List<Category>> fetchCategories() async {
    try {
      final response = await getAuthenticatedRequest('category');

      if (response.statusCode == 200) {
        final categoryResponse = CategoryResponse.fromJson(json.decode(response.body));
        return categoryResponse.data;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw e;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Auth-Key': ApiConfig.authKey,
        },
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw TimeoutException('Connection timed out. Server is taking too long to respond.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }


  // Add this method to your ApiService class



  Future<bool> addMenuItem({
    required String name,
    required int categoryId,
    required double price,
    required String description,
    bool isVeg = false,
    bool isAddon = false,
    bool isActive = true,
    // Map<String, dynamic> quantities = const {},
    required List<Map<String, dynamic>> quantities,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'category_id': categoryId,
        'price': price.toStringAsFixed(2),
        'description': description,
        'is_veg': isVeg,
        'is_addon': isAddon,
        'is_active': isActive,
        'quantities': quantities,
      };

      // Try the direct API endpoint first with enhanced headers
      var response = await _tryApiRequest(
        'item',
        requestBody,
        extraHeaders: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest', // Helps identify AJAX requests
        },
      );

      // If still redirected, follow the redirect manually
      if (response.statusCode == 302) {
        print('Received redirect to: ${response.headers['location']}');
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Try to follow the redirect with the same payload
          final token = await TokenStorage.getToken();
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'X-Auth-Key': ApiConfig.authKey,
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-API-Request': 'true',
          };

          final Uri redirectUri;
          if (redirectUrl.startsWith('http')) {
            redirectUri = Uri.parse(redirectUrl);
          } else {
            // Handle relative URLs
            redirectUri = Uri.parse('${ApiConfig.baseUrl}$redirectUrl'.replaceAll('//', '/'));
          }

          final client = http.Client();
          try {
            response = await client.post(
              redirectUri,
              headers: headers,
              body: jsonEncode(requestBody),
            );
          } finally {
            client.close();
          }
        }
      }

      // Debug information
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  Future<http.Response> _tryApiRequest(String endpoint, dynamic body, {Map<String, String>? extraHeaders}) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Auth-Key': ApiConfig.authKey,
      ...?extraHeaders,
    };

    print('Making request to $url');
    print('Headers: $headers');
    print('Body: $body');

    final client = http.Client();
    try {
      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } finally {
      client.close();
    }
  }


// Optionally, add a method to fetch menu items by category if needed
  Future<List<MenuItem>> fetchMenuItemsByCategory(int categoryId) async {
    try {
      final response = await getAuthenticatedRequest('item?category_id=$categoryId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load menu items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      throw e;
    }
  }




  Future<TodaysMenuResponse> fetchTodaysMenu() async {
    try {
      final response = await getAuthenticatedRequest(
          'todays-menu?include=item,item.category,item.item_images,item.quantities,item.quantities.prices'
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response body');
        }
        return TodaysMenuResponse.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Failed to load today\'s menu: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching today\'s menu: $e');
      throw e;
    }
  }





  Future<bool> addToTodaysMenu(int itemId) async {
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}todays-menu');

      // Create the request body with more details
      final request = TodaysMenuAddRequest(
        itemId: itemId,
        totalQuantity: 30,  // You might want to make this configurable
        isActive: true,
      );

      print('===== ADD TO TODAY\'S MENU REQUEST =====');
      print('URL: $url');
      print('Token available: ${token != null ? 'Yes' : 'No'}');
      print('Request body: ${jsonEncode(request.toJson())}');

      // Use enhanced headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Auth-Key': ApiConfig.authKey,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

      print('Request headers: $headers');

      // Create a client for more control
      final client = http.Client();
      http.Response response;

      try {
        response = await client.post(
          url,
          headers: headers,
          body: jsonEncode(request.toJson()),
        ).timeout(
          AppConstants.apiTimeout,
          onTimeout: () {
            throw TimeoutException('Connection timed out. Server is taking too long to respond.');
          },
        );
      } finally {
        client.close();
      }

      print('===== ADD TO TODAY\'S MENU RESPONSE =====');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      // Handle redirect (if any)
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        print('Redirected to: $location');

        if (location != null) {
          final redirectUrl = location.startsWith('http')
              ? location
              : '${ApiConfig.baseUrl}$location'.replaceAll('//', '/');

          print('Following redirect to: $redirectUrl');

          final redirectResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: headers,
            body: jsonEncode(request.toJson()),
          );

          print('Redirect status code: ${redirectResponse.statusCode}');
          print('Redirect response body: ${redirectResponse.body}');

          response = redirectResponse;
        }
      }

      // Process response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          print('Success message: ${responseData['message'] ?? 'No message'}');

          // You might want to parse the full response for additional information
          try {
            final addResponse = TodaysMenuAddResponse.fromJson(responseData);
            print('Added item with ID: ${addResponse.data.id}');
          } catch (parseError) {
            print('Non-critical error parsing response: $parseError');
          }

          return true;
        } catch (e) {
          print('Error parsing successful response: $e');
          return true; // Still return true if status code is successful
        }
      } else {
        String errorDetails = 'Status: ${response.statusCode}';

        try {
          final responseData = jsonDecode(response.body);
          errorDetails += ', Message: ${responseData['message'] ?? 'Unknown error'}';
          if (responseData['errors'] != null) {
            errorDetails += ', Errors: ${responseData['errors']}';
          }
        } catch (e) {
          errorDetails += ', Body: ${response.body}';
        }

        print('Failed to add to today\'s menu: $errorDetails');
        return false;
      }
    } catch (e) {
      print('Exception in addToTodaysMenu: $e');
      return false;
    }
  }

  Future<bool> removeFromTodaysMenu(int todaysMenuItemId) async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}todays-menu/$todaysMenuItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Auth-Key': ApiConfig.authKey,
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw TimeoutException(
              'Connection timed out. Server is taking too long to respond.');
        },
      );

      print('Remove from today\'s menu response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing from today\'s menu: $e');
      return false;
    }
  }




}



// Add this method to your ApiService class
