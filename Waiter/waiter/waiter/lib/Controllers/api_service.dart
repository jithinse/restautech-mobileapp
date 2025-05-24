import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../controllers/auth_controller.dart';
import '../model/menuformenucart.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class ApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
    ),
  );

  // Token refresh mechanism
  static Future<bool> _refreshToken() async {
    try {
      _logger.d('Attempting to refresh token...');
      final credentials = await TokenStorage.getCredentials();

      if (credentials['email'] == null || credentials['password'] == null) {
        _logger.w('No saved credentials available for token refresh');
        return false;
      }

      final loginResult = await AuthController.login(
        credentials['email']!,
        credentials['password']!,
      );

      if (loginResult['success'] == true) {
        _logger.i('Token refreshed successfully');
        return true;
      } else {
        _logger.w('Token refresh failed: ${loginResult['message']}');
        return false;
      }
    } catch (e) {
      _logger.e('Error during token refresh', error: e);
      return false;
    }
  }

  // Unified request handler
  static Future<http.Response> _makeAuthenticatedRequest({
    required Future<http.Response> Function() requestFn,
    int maxRetries = 1,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final response = await requestFn();

        if (response.statusCode == 401 && retryCount < maxRetries) {
          _logger.w('Token expired, attempting to refresh...');
          final refreshSuccess = await _refreshToken();
          if (refreshSuccess) {
            retryCount++;
            continue;
          }
        }

        return response;
      } on TimeoutException catch (e) {
        _logger.e('Request timeout', error: e);
        throw TimeoutException('Request timed out. Please try again.');
      } catch (e) {
        _logger.e('Request error', error: e);
        rethrow;
      }
    }

    await TokenStorage.clear();
    throw Exception('Session expired. Please login again.');
  }

  // Error handling
  static String handleException(dynamic e) {
    if (e is SocketException) {
      return 'Network error: No internet connection';
    } else if (e is TimeoutException) {
      return 'Request timed out. Please try again';
    } else if (e is HttpException) {
      return 'HTTP error: ${e.message}';
    } else if (e is FormatException) {
      return 'Data format error: ${e.message}';
    } else if (e.toString().contains('401')) {
      return 'Session expired. Please login again.';
    } else {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Generic GET request with authentication
  static Future<http.Response> getAuthenticatedRequest(String endpoint) async {
    return await _makeAuthenticatedRequest(
      requestFn: () async {
        _logger.d('GET request to: $endpoint');
        String? token = await TokenStorage.getToken();

        if (token == null) {
          throw Exception('Authentication required');
        }

        final stopwatch = Stopwatch()..start();
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: ApiConstants.timeoutDuration));

        _logger.i(
            'GET completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
        return response;
      },
    );
  }

  // Generic POST request with authentication
  // static Future<http.Response> postAuthenticatedRequest(
  //   String endpoint,
  //   dynamic body,
  // ) async {
  //   return await _makeAuthenticatedRequest(
  //     requestFn: () async {
  //       _logger.d('POST request to: $endpoint');
  //       _logger.v('Request body: $body');
  //
  //       String? token = await TokenStorage.getToken();
  //       if (token == null) {
  //         throw Exception('Authentication required');
  //       }
  //
  //       final stopwatch = Stopwatch()..start();
  //       final response = await http
  //           .post(
  //             Uri.parse('${ApiConstants.baseUrl}$endpoint'),
  //             headers: {
  //               'Content-Type': 'application/json',
  //               'Authorization': 'Bearer $token',
  //             },
  //             body: jsonEncode(body),
  //           )
  //           .timeout(const Duration(seconds: ApiConstants.timeoutDuration));
  //
  //       _logger.i(
  //           'POST completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
  //       return response;
  //     },
  //   );
  // }

// Modify postAuthenticatedRequest method in ApiService class to handle redirects

  // static Future<http.Response> postAuthenticatedRequest(
  //     String endpoint,
  //     dynamic body,
  //     ) async {
  //   return await _makeAuthenticatedRequest(
  //     requestFn: () async {
  //       _logger.d('POST request to: $endpoint');
  //       _logger.v('Request body: $body');
  //
  //       String? token = await TokenStorage.getToken();
  //       if (token == null) {
  //         throw Exception('Authentication required');
  //       }
  //
  //       // Make sure the URL is correct and ends with a slash if needed
  //       String url = '${ApiConstants.baseUrl}$endpoint';
  //       if (!url.endsWith('/') && ApiConstants.baseUrl.endsWith('/')) {
  //         url = '$url/';  // Ensure consistent trailing slash
  //       }
  //
  //       final stopwatch = Stopwatch()..start();
  //
  //       // Create a client that follows redirects
  //       final client = http.Client();
  //       try {
  //         final response = await client.post(
  //           Uri.parse(url),
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Authorization': 'Bearer $token',
  //             'Accept': 'application/json',  // Explicitly request JSON response
  //           },
  //           body: jsonEncode(body),
  //         ).timeout(const Duration(seconds: ApiConstants.timeoutDuration));
  //
  //         _logger.i(
  //             'POST completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
  //
  //         // If we still get a redirect, log the location header for debugging
  //         if (response.statusCode == 302 || response.statusCode == 301) {
  //           _logger.w('Redirect detected to: ${response.headers['location']}');
  //         }
  //
  //         return response;
  //       } finally {
  //         client.close();
  //       }
  //     },
  //   );
  // }
  static Future<http.Response> postAuthenticatedRequest(
    String endpoint,
    dynamic body,
  ) async {
    return await _makeAuthenticatedRequest(
      requestFn: () async {
        _logger.d('POST request to: $endpoint');
        _logger.v('Request body: $body');

        String? token = await TokenStorage.getToken();
        if (token == null) {
          throw Exception('Authentication required');
        }

        // Ensure base URL ends with '/', but endpoint does not start with '/'
        String base = ApiConstants.baseUrl;
        if (!base.endsWith('/')) base = '$base/';
        if (endpoint.startsWith('/')) endpoint = endpoint.substring(1);

        String url = '$base$endpoint';

        print('Final POST URL: $url');

        final stopwatch = Stopwatch()..start();

        final client = http.Client();
        try {
          final response = await client
              .post(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

          _logger.i(
              'POST completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');

          // Log if redirect happens
          if (response.statusCode == 301 || response.statusCode == 302) {
            _logger.w('Redirect detected to: ${response.headers['location']}');
          }

          return response;
        } finally {
          client.close();
        }
      },
    );
  }

  // Generic PUT request with authentication
  static Future<http.Response> putAuthenticatedRequest(
    String endpoint,
    dynamic body,
  ) async {
    return await _makeAuthenticatedRequest(
      requestFn: () async {
        _logger.d('PUT request to: $endpoint');
        _logger.v('Request body: $body');

        String? token = await TokenStorage.getToken();
        if (token == null) {
          throw Exception('Authentication required');
        }

        final stopwatch = Stopwatch()..start();
        final response = await http
            .put(
              Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

        _logger.i(
            'PUT completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
        return response;
      },
    );
  }

  // Generic PATCH request with authentication
  static Future<http.Response> patchAuthenticatedRequest(
    String endpoint,
    dynamic body,
  ) async {
    return await _makeAuthenticatedRequest(
      requestFn: () async {
        _logger.d('PATCH request to: $endpoint');
        _logger.v('Request body: $body');

        String? token = await TokenStorage.getToken();
        if (token == null) {
          throw Exception('Authentication required');
        }

        final stopwatch = Stopwatch()..start();
        final response = await http
            .patch(
              Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

        _logger.i(
            'PATCH completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
        return response;
      },
    );
  }

  // Generic DELETE request with authentication
  static Future<http.Response> deleteAuthenticatedRequest(
      String endpoint) async {
    return await _makeAuthenticatedRequest(
      requestFn: () async {
        _logger.d('DELETE request to: $endpoint');

        String? token = await TokenStorage.getToken();
        if (token == null) {
          throw Exception('Authentication required');
        }

        final stopwatch = Stopwatch()..start();
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: ApiConstants.timeoutDuration));

        _logger.i(
            'DELETE completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
        return response;
      },
    );
  }

  // Login request with API key
  static Future<http.Response> postWithApiKey(
    String endpoint,
    dynamic body,
  ) async {
    try {
      _logger.d('POST with API key to: $endpoint');
      _logger.v('Request body: $body');

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConstants.authKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

      _logger.i(
          'POST with API key completed in ${stopwatch.elapsedMilliseconds}ms - Status: ${response.statusCode}');
      return response;
    } on TimeoutException catch (e) {
      _logger.e('Timeout in postWithApiKey', error: e);
      throw TimeoutException('Request timed out. Please try again.');
    } catch (e) {
      _logger.e('Error in postWithApiKey', error: e);
      rethrow;
    }
  }

  // Menu API Methods
  static Future<MenuResponse> fetchTodaysMenu() async {
    try {
      final endpoint =
          'todays-menu?include=item,item.category,item.item_images,item.quantities,item.quantities.prices';
      final response = await getAuthenticatedRequest(endpoint);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return MenuResponse.fromJson(jsonData);
      } else {
        _logger.e('API error: ${response.statusCode} - ${response.body}');
        return MenuResponse.empty();
      }
    } on TimeoutException {
      _logger.e('Request timeout');
      return MenuResponse.empty();
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return MenuResponse.empty();
    }
  }

  static Future<CategoryResponse> fetchCategories() async {
    try {
      final response = await getAuthenticatedRequest('category');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return CategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (e) {
      _logger.e('Error fetching categories', error: e);
      throw Exception('Failed to load categories: ${e.toString()}');
    }
  }

  // Order API Methods
  static Future<Map<String, dynamic>> getOrders({
    int limit = 100,
    List<String> includes = const ['tables', 'user', 'items'],
    String sort = '-created_at',
  }) async {
    try {
      final includeParam = includes.join(',');
      final endpoint = 'order?limit=$limit&include=$includeParam&sort=$sort';

      final response = await getAuthenticatedRequest(endpoint);
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': response.statusCode == 200,
        'data': responseData['data'],
        'message': responseData['message'] ??
            (response.statusCode == 200
                ? 'Orders fetched successfully'
                : 'Failed to fetch orders'),
      };
    } catch (e) {
      _logger.e('Error in getOrders', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }

  //  static Future<Map<String, dynamic>> createOrder(
  //   Map<String, dynamic> orderData,
  // ) async {
  //   try {
  //     // Validate input data
  //     if (orderData['items'] == null || (orderData['items'] as List).isEmpty) {
  //       throw Exception('Order must contain at least one item');
  //     }
  //
  //     // Prepare payload
  //     final apiPayload = {
  //       'order_type': orderData['order_type'] ?? 'dine_in',
  //       'remarks': orderData['remarks'] ?? '',
  //       'order_items': (orderData['items'] as List).map((item) {
  //         if (item['item_id'] == null) {
  //           throw Exception('All items must have an item_id');
  //         }
  //         return {
  //           'item_id': item['item_id'],
  //           'quantity_id': item['quantity_id'] ?? 1,
  //           'total_quantity': item['total_quantity'] ?? 1,
  //         };
  //       }).toList(),
  //       'tables': (orderData['tables'] as List? ?? []).map((table) {
  //         return {
  //           'table_id': table['table_id'] ?? 0,
  //           'seats_used': table['seats_used'] ?? 1,
  //         };
  //       }).toList(),
  //     };
  //
  //     _logger.d('Order payload: ${jsonEncode(apiPayload)}');
  //
  //     final response = await postAuthenticatedRequest('order', apiPayload);
  //
  //     // Handle different response types
  //     if (response.body.trim().startsWith('<!DOCTYPE html>')) {
  //       throw FormatException('Server returned HTML error page');
  //     }
  //
  //     final responseData = json.decode(response.body);
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'data': responseData['data'],
  //         'message': responseData['message'] ?? 'Order created successfully',
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': responseData['message'] ?? 'Failed to create order',
  //         'statusCode': response.statusCode,
  //       };
  //     }
  //   } on FormatException catch (e) {
  //     _logger.e('Format error in createOrder', error: e);
  //     return {
  //       'success': false,
  //       'message': 'Server error: Invalid response format',
  //     };
  //   } catch (e) {
  //     _logger.e('Error in createOrder', error: e);
  //     return {
  //       'success': false,
  //       'message': handleException(e),
  //     };
  //   }
  //
  // }

  static Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final response = await getAuthenticatedRequest(
          'order/$orderId?include=tables,user,items');
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': response.statusCode == 200,
        'data': responseData['data'],
        'message': responseData['message'] ??
            (response.statusCode == 200
                ? 'Order fetched successfully'
                : 'Failed to fetch order'),
      };
    } catch (e) {
      _logger.e('Error in getOrder', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }

  static Future<Map<String, dynamic>> updateOrder(
    int orderId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await patchAuthenticatedRequest(
        'order/$orderId',
        updateData,
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': response.statusCode == 200,
        'data': responseData['data'],
        'message': responseData['message'] ??
            (response.statusCode == 200
                ? 'Order updated successfully'
                : 'Failed to update order'),
      };
    } catch (e) {
      _logger.e('Error in updateOrder', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      final response = await postAuthenticatedRequest(
        'order/$orderId/update-status',
        {'status': status},
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': response.statusCode == 200,
        'data': responseData['data'],
        'message': responseData['message'] ??
            (response.statusCode == 200
                ? 'Order status updated successfully'
                : 'Failed to update order status'),
      };
    } catch (e) {
      _logger.e('Error in updateOrderStatus', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }

  // Helper method to prepare order data
  static Map<String, dynamic> prepareOrderData({
    required int restaurantId,
    required int tableId,
    required List<CartItem> items,
    required int guestCount,
    required String orderType,
    String? remarks,
  }) {
    return {
      'restaurant_id': restaurantId,
      'order_type': orderType,
      'remarks': remarks ?? '',
      'items': items.map((item) {
        return {
          'item_id': item.menuItem.item.id,
          'quantity_id':
              item.selectedSize, // Changed from quantity_type to quantity_id
          'total_quantity': item.quantity,
        };
      }).toList(),
      'tables': [
        {
          'table_id': tableId,
          'seats_used':
              guestCount, // Note: Make sure this matches your API (seats_used vs seats_used)
        }
      ],
    };
  }

  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      _logger.d('Creating order with data: ${json.encode(orderData)}');

      // Basic validation
      if (orderData['order_items'] == null ||
          (orderData['order_items'] as List).isEmpty) {
        return {
          'success': false,
          'message': 'Order must contain at least one item',
        };
      }

      // Try different endpoint formats if needed
      // First attempt with normal endpoint
      var result = await _tryCreateOrder(orderData, 'order');

      // If redirect happened, try with trailing slash
      if (!result['success'] &&
          result['message']?.contains('redirect') == true) {
        _logger.w('Retrying with trailing slash');
        result = await _tryCreateOrder(orderData, 'order/');
      }

      return result;
    } catch (e) {
      _logger.e('Error in createOrder', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }

// Helper method to attempt order creation with different endpoint formats
  static Future<Map<String, dynamic>> _tryCreateOrder(
      Map<String, dynamic> orderData, String endpoint) async {
    try {
      // Use a client that can follow redirects
      final client = http.Client();
      String? token = await TokenStorage.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      try {
        final response = await client
            .post(
              Uri.parse('${ApiConstants.baseUrl}$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
              body: jsonEncode(orderData),
            )
            .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

        _logger.d('Order API response code: ${response.statusCode}');

        // Check if we're still getting redirected
        if (response.statusCode == 302 || response.statusCode == 301) {
          final location = response.headers['location'];
          _logger.w('API redirecting to: $location');

          // If we know where it's redirecting, we could follow manually
          if (location != null && location.isNotEmpty) {
            _logger.i('Manually following redirect to $location');

            // Make a second request to the redirect location
            final redirectResponse = await client
                .post(
                  Uri.parse(location),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(orderData),
                )
                .timeout(const Duration(seconds: ApiConstants.timeoutDuration));

            return _processOrderResponse(redirectResponse);
          }

          return {
            'success': false,
            'message':
                'Server redirected the request. Please check your API endpoint configuration.',
            'redirect_location': location,
          };
        }

        return _processOrderResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      _logger.e('Error in _tryCreateOrder', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }




// Helper to process HTTP response
  static Map<String, dynamic> _processOrderResponse(http.Response response) {
    try {
      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        _logger.e('API returned HTML instead of JSON');
        return {
          'success': false,
          'message':
              'Received invalid response format from server. Please contact support.',
        };
      }

      // Parse the JSON
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Order created successfully',
        };
      } else {
        String errorMessage = 'Failed to create order';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on FormatException catch (e) {
      _logger.e('JSON parsing error', error: e);
      return {
        'success': false,
        'message': 'Server returned an invalid response format.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing response: ${e.toString()}',
      };
    }
  }

  // Add this to the ApiService class

// Check API connectivity and configuration
  static Future<Map<String, dynamic>> checkApiConnection() async {
    try {
      _logger.d('Checking API connectivity to: ${ApiConstants.baseUrl}');

      try {
        // First try with ping endpoint
        final pingUrl = ApiConstants.getFullUrl('ping');
        _logger.d('Checking ping endpoint: $pingUrl');

        final client = http.Client();
        try {
          final response = await client.get(
            Uri.parse(pingUrl),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          // If we get a redirect, there might be an issue with the base URL
          if (response.statusCode == 301 || response.statusCode == 302) {
            final location = response.headers['location'];
            _logger.w('API URL is redirecting to: $location');

            // Try to diagnose the issue
            if (location != null) {
              if (location.contains('index.php')) {
                return {
                  'success': false,
                  'message':
                      'API redirecting to index.php. Your server might be using .htaccess to redirect API calls. ' +
                          'Please check your API URL configuration or server settings.',
                  'redirect_location': location,
                };
              }

              // Try to make a request to the redirect location
              _logger.i('Trying redirect location: $location');
              final redirectResponse = await client.get(
                Uri.parse(location),
                headers: {'Accept': 'application/json'},
              ).timeout(const Duration(seconds: 5));

              if (redirectResponse.statusCode == 200) {
                return {
                  'success': true,
                  'message': 'API connection successful after redirect. ' +
                      'Consider updating your base URL to avoid redirects.',
                  'suggested_url': location,
                };
              }
            }

            return {
              'success': false,
              'message':
                  'API URL is redirecting. Please check your baseUrl configuration in constants.dart',
              'redirect_location': location,
            };
          }

          // Check normal response
          if (response.statusCode == 200) {
            _logger.i('API connection successful (${response.statusCode})');
            return {
              'success': true,
              'message': 'API connection successful',
              'status': response.statusCode,
            };
          } else {
            // Try alternate endpoint in case 'ping' is not valid
            _logger.w(
                'Ping endpoint returned ${response.statusCode}, trying order endpoint...');

            // Check if we have auth token
            String? token = await TokenStorage.getToken();
            final Map<String, String> headers = {'Accept': 'application/json'};

            if (token != null) {
              headers['Authorization'] = 'Bearer $token';
            }

            final orderResponse = await client
                .get(
                  Uri.parse(ApiConstants.getFullUrl('order')),
                  headers: headers,
                )
                .timeout(const Duration(seconds: 5));

            return {
              'success': orderResponse.statusCode != 404,
              'message': orderResponse.statusCode != 404
                  ? 'API connection successful (${orderResponse.statusCode})'
                  : 'API endpoints not found. Please verify your API URL.',
              'status': orderResponse.statusCode,
            };
          }
        } finally {
          client.close();
        }
      } on FormatException {
        return {
          'success': false,
          'message': 'Invalid API URL format',
        };
      } on SocketException {
        return {
          'success': false,
          'message':
              'Cannot connect to the API server. Check your internet connection or API URL.',
        };
      } on TimeoutException {
        return {
          'success': false,
          'message': 'API connection timed out',
        };
      }
    } catch (e) {
      _logger.e('Error checking API connection', error: e);
      return {
        'success': false,
        'message': 'Error checking API connection: ${e.toString()}',
      };
    }
  }




  // Add this to your ApiService class
  static Future<Map<String, dynamic>> updateOrderStatusorder({
    required int orderId,
    required String status,
  }) async {
    try {
      final endpoint = 'order/$orderId/update-status';
      final response = await postAuthenticatedRequest(
        endpoint,
        {'status': status},
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'success': response.statusCode == 200,
        'data': responseData['data'],
        'message': responseData['message'] ??
            (response.statusCode == 200
                ? 'Status updated successfully'
                : 'Failed to update status'),
      };
    } catch (e) {
      _logger.e('Error in updateOrderStatus', error: e);
      return {
        'success': false,
        'message': handleException(e),
      };
    }
  }
}
