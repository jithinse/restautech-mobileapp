// class ApiConstants {
//   static const String baseUrl =
//       "https://ivory-antelope-869726.hostingersite.com/api/v1/";
//   static const String authKey = "29B37-89DFC5E37A525891-FE788E23";
//
//   // API Endpoints
//   static const String loginEndpoint = "login";
//   static const String forgotPasswordEndpoint = 'change-password';
//   static const String orderEndpoint = 'order';
//   // Timeout duration
//   static const int timeoutDuration = 15; // in seconds
// }
//
// class UIConstants {
//   static const double defaultPadding = 16.0;
//   static const double cardPadding = 24.0;
//   static const double buttonHeight = 50.0;
// }

class ApiConstants {
  // Make sure the baseUrl ends with a trailing slash
  static const String baseUrl =
      "https://ivory-antelope-869726.hostingersite.com/api/v1/";
  static const String authKey = "29B37-89DFC5E37A525891-FE788E23";

  // API Endpoints - no need for trailing slashes since baseUrl has one
  static const String loginEndpoint = "login";
  static const String forgotPasswordEndpoint = 'change-password';
  static const String orderEndpoint = 'order';

  // Timeout duration
  static const int timeoutDuration = 15; // in seconds

  // Helper method to get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    // Ensure we don't have double slashes
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    return baseUrl + endpoint;
  }
}