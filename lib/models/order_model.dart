//
//
//
//
// // order_model.dart - Fix for type conversion errors
//
// class OrderResponse {
//   final String message;
//   final List<Order> data;
//
//   OrderResponse({required this.message, required this.data});
//
//   factory OrderResponse.fromJson(Map<String, dynamic> json) {
//     return OrderResponse(
//       message: json['message'],
//       data: (json['data'] as List).map((i) => Order.fromJson(i)).toList(),
//     );
//   }
// }
//
// class Order {
//   final int id;
//   final String orderId;
//   final int restaurantId;
//   final int tableId;
//   final Table table;
//   final String orderedBy;
//   final int createdBy;
//   final User user;
//   final String status;
//   final double totalPrice;
//   final String orderType;
//   final String? remarks;
//   final DateTime createdAt;
//   final List<OrderItem> items;
//
//   Order({
//     required this.id,
//     required this.orderId,
//     required this.restaurantId,
//     required this.tableId,
//     required this.table,
//     required this.orderedBy,
//     required this.createdBy,
//     required this.user,
//     required this.status,
//     required this.totalPrice,
//     required this.orderType,
//     this.remarks,
//     required this.createdAt,
//     required this.items,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     // Safe conversion functions
//     int parseIntSafely(dynamic value) {
//       if (value is int) return value;
//       if (value is String) return int.parse(value);
//       if (value is double) return value.toInt();
//       return 0; // Default value
//     }
//
//     double parseDoubleSafely(dynamic value) {
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.parse(value);
//       return 0.0; // Default value
//     }
//
//     return Order(
//       id: parseIntSafely(json['id']),
//       orderId: json['order_id'].toString(),
//       restaurantId: parseIntSafely(json['restaurant_id']),
//       tableId: parseIntSafely(json['table_id']),
//       table: Table.fromJson(json['table']),
//       orderedBy: json['ordered_by'].toString(),
//       createdBy: parseIntSafely(json['created_by']),
//       user: User.fromJson(json['user']),
//       status: json['status'].toString(),
//       totalPrice: parseDoubleSafely(json['total_price']),
//       orderType: json['order_type'].toString(),
//       remarks: json['remarks']?.toString(),
//       createdAt: DateTime.parse(json['created_at'].toString()),
//       items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
//     );
//   }
//
//   String get formattedTime {
//     final now = DateTime.now();
//     final difference = now.difference(createdAt);
//
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }
//
// class Table {
//   final int id;
//   final int restaurantId;
//   final String tableNumber;
//   final String uniqueToken;
//   final bool isOccupied;
//   final bool isActive;
//
//   Table({
//     required this.id,
//     required this.restaurantId,
//     required this.tableNumber,
//     required this.uniqueToken,
//     required this.isOccupied,
//     required this.isActive,
//   });
//
//   factory Table.fromJson(Map<String, dynamic> json) {
//     // Safe conversion functions
//     int parseIntSafely(dynamic value) {
//       if (value is int) return value;
//       if (value is String) return int.parse(value);
//       if (value is double) return value.toInt();
//       return 0; // Default value
//     }
//
//     bool parseBoolSafely(dynamic value) {
//       if (value is bool) return value;
//       if (value is int) return value == 1;
//       if (value is String) return value.toLowerCase() == 'true' || value == '1';
//       return false; // Default value
//     }
//
//     return Table(
//       id: parseIntSafely(json['id']),
//       restaurantId: parseIntSafely(json['restaurant_id']),
//       tableNumber: json['table_number'].toString(),
//       uniqueToken: json['unique_token'].toString(),
//       isOccupied: parseBoolSafely(json['is_occupied']),
//       isActive: parseBoolSafely(json['is_active']),
//     );
//   }
// }
//
// class User {
//   final int id;
//   final int vendorId;
//   final int restaurantId;
//   final String name;
//   final String email;
//   final String countryCode;
//   final String phone;
//   final String imagePath;
//   final String role;
//
//   User({
//     required this.id,
//     required this.vendorId,
//     required this.restaurantId,
//     required this.name,
//     required this.email,
//     required this.countryCode,
//     required this.phone,
//     required this.imagePath,
//     required this.role,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     // Safe conversion function
//     int parseIntSafely(dynamic value) {
//       if (value is int) return value;
//       if (value is String) return int.parse(value);
//       if (value is double) return value.toInt();
//       return 0; // Default value
//     }
//
//     return User(
//       id: parseIntSafely(json['id']),
//       vendorId: parseIntSafely(json['vendor_id']),
//       restaurantId: parseIntSafely(json['restaurant_id']),
//       name: json['name'].toString(),
//       email: json['email'].toString(),
//       countryCode: json['country_code'].toString(),
//       phone: json['phone'].toString(),
//       imagePath: json['image_path'].toString(),
//       role: json['role'].toString(),
//     );
//   }
// }
//
// class OrderItem {
//   final int id;
//   final String name;
//   final String category;
//   final String quantityType;
//   final double price;
//   final int totalQuantity;
//   final double subtotal;
//   final String description;
//   final bool isAddon;
//   final bool isVeg;
//
//   OrderItem({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.quantityType,
//     required this.price,
//     required this.totalQuantity,
//     required this.subtotal,
//     required this.description,
//     required this.isAddon,
//     required this.isVeg,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     // Safe conversion functions
//     int parseIntSafely(dynamic value) {
//       if (value is int) return value;
//       if (value is String) return int.parse(value);
//       if (value is double) return value.toInt();
//       return 0; // Default value
//     }
//
//     double parseDoubleSafely(dynamic value) {
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.parse(value);
//       return 0.0; // Default value
//     }
//
//     bool parseBoolSafely(dynamic value) {
//       if (value is bool) return value;
//       if (value is int) return value == 1;
//       if (value is String) return value.toLowerCase() == 'true' || value == '1';
//       return false; // Default value
//     }
//
//     return OrderItem(
//       id: parseIntSafely(json['id']),
//       name: json['name'].toString(),
//       category: json['category'].toString(),
//       quantityType: json['quantity_type'].toString(),
//       price: parseDoubleSafely(json['price']),
//       totalQuantity: parseIntSafely(json['total_quantity']),
//       subtotal: parseDoubleSafely(json['subtotal']),
//       description: json['description'].toString(),
//       isAddon: parseBoolSafely(json['is_addon']),
//       isVeg: parseBoolSafely(json['is_veg']),
//     );
//   }
//
//
// }



// order_model.dart - Fully null-safe implementation

class OrderResponse {
  final String message;
  final List<Order> data;

  OrderResponse({required this.message, required this.data});

  factory OrderResponse.empty() => OrderResponse(
    message: 'No orders available',
    data: [],
  );

  factory OrderResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderResponse.empty();

    try {
      return OrderResponse(
        message: json['message']?.toString() ?? 'No message',
        data: (json['data'] as List?)?.map((i) => Order.fromJson(i)).toList() ?? [],
      );
    } catch (e) {
      print('Error parsing OrderResponse: $e');
      return OrderResponse.empty();
    }
  }
}

class Order {
  final int id;
  final String orderId;
  final int restaurantId;
  final int tableId;
  final Table table;
  final String orderedBy;
  final int createdBy;
  final User user;
  final String status;
  final double totalPrice;
  final String orderType;
  final String? remarks;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.tableId,
    required this.table,
    required this.orderedBy,
    required this.createdBy,
    required this.user,
    required this.status,
    required this.totalPrice,
    required this.orderType,
    this.remarks,
    required this.createdAt,
    required this.items,
  });

  factory Order.empty() => Order(
    id: 0,
    orderId: '',
    restaurantId: 0,
    tableId: 0,
    table: Table.empty(),
    orderedBy: '',
    createdBy: 0,
    user: User.empty(),
    status: '',
    totalPrice: 0.0,
    orderType: '',
    remarks: null,
    createdAt: DateTime.now(),
    items: [],
  );

  factory Order.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Order.empty();

    // Safe conversion functions
    int parseIntSafely(dynamic value) => value != null
        ? (value is int ? value :
    (value is String ? int.tryParse(value) ?? 0 :
    (value is double ? value.toInt() : 0)))
        : 0;

    double parseDoubleSafely(dynamic value) => value != null
        ? (value is double ? value :
    (value is int ? value.toDouble() :
    (value is String ? double.tryParse(value) ?? 0.0 : 0.0)))
        : 0.0;

    DateTime parseDateTimeSafely(dynamic value) {
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return Order(
      id: parseIntSafely(json['id']),
      orderId: json['order_id']?.toString() ?? '',
      restaurantId: parseIntSafely(json['restaurant_id']),
      tableId: parseIntSafely(json['table_id']),
      table: Table.fromJson(json['table']),
      orderedBy: json['ordered_by']?.toString() ?? '',
      createdBy: parseIntSafely(json['created_by']),
      user: User.fromJson(json['user']),
      status: json['status']?.toString() ?? 'unknown',
      totalPrice: parseDoubleSafely(json['total_price']),
      orderType: json['order_type']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      createdAt: parseDateTimeSafely(json['created_at']),
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class Table {
  final int id;
  final int restaurantId;
  final String tableNumber;
  final String uniqueToken;
  final bool isOccupied;
  final bool isActive;

  Table({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.uniqueToken,
    required this.isOccupied,
    required this.isActive,
  });

  factory Table.empty() => Table(
    id: 0,
    restaurantId: 0,
    tableNumber: '',
    uniqueToken: '',
    isOccupied: false,
    isActive: false,
  );

  factory Table.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Table.empty();

    int parseIntSafely(dynamic value) => value != null
        ? (value is int ? value :
    (value is String ? int.tryParse(value) ?? 0 :
    (value is double ? value.toInt() : 0)))
        : 0;

    bool parseBoolSafely(dynamic value) => value != null
        ? (value is bool ? value :
    (value is int ? value == 1 :
    (value is String ? value.toLowerCase() == 'true' || value == '1' : false)))
        : false;

    return Table(
      id: parseIntSafely(json['id']),
      restaurantId: parseIntSafely(json['restaurant_id']),
      tableNumber: json['table_number']?.toString() ?? '',
      uniqueToken: json['unique_token']?.toString() ?? '',
      isOccupied: parseBoolSafely(json['is_occupied']),
      isActive: parseBoolSafely(json['is_active']),
    );
  }
}

class User {
  final int id;
  final int vendorId;
  final int restaurantId;
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String imagePath;
  final String role;

  User({
    required this.id,
    required this.vendorId,
    required this.restaurantId,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.imagePath,
    required this.role,
  });

  factory User.empty() => User(
    id: 0,
    vendorId: 0,
    restaurantId: 0,
    name: '',
    email: '',
    countryCode: '',
    phone: '',
    imagePath: '',
    role: '',
  );

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User.empty();

    int parseIntSafely(dynamic value) => value != null
        ? (value is int ? value :
    (value is String ? int.tryParse(value) ?? 0 :
    (value is double ? value.toInt() : 0)))
        : 0;

    return User(
      id: parseIntSafely(json['id']),
      vendorId: parseIntSafely(json['vendor_id']),
      restaurantId: parseIntSafely(json['restaurant_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final String category;
  final String quantityType;
  final double price;
  final int totalQuantity;
  final double subtotal;
  final String description;
  final bool isAddon;
  final bool isVeg;

  OrderItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantityType,
    required this.price,
    required this.totalQuantity,
    required this.subtotal,
    required this.description,
    required this.isAddon,
    required this.isVeg,
  });

  factory OrderItem.empty() => OrderItem(
    id: 0,
    name: '',
    category: '',
    quantityType: '',
    price: 0.0,
    totalQuantity: 0,
    subtotal: 0.0,
    description: '',
    isAddon: false,
    isVeg: false,
  );

  factory OrderItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderItem.empty();

    int parseIntSafely(dynamic value) => value != null
        ? (value is int ? value :
    (value is String ? int.tryParse(value) ?? 0 :
    (value is double ? value.toInt() : 0)))
        : 0;

    double parseDoubleSafely(dynamic value) => value != null
        ? (value is double ? value :
    (value is int ? value.toDouble() :
    (value is String ? double.tryParse(value) ?? 0.0 : 0.0)))
        : 0.0;

    bool parseBoolSafely(dynamic value) => value != null
        ? (value is bool ? value :
    (value is int ? value == 1 :
    (value is String ? value.toLowerCase() == 'true' || value == '1' : false)))
        : false;

    return OrderItem(
      id: parseIntSafely(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      quantityType: json['quantity_type']?.toString() ?? '',
      price: parseDoubleSafely(json['price']),
      totalQuantity: parseIntSafely(json['total_quantity']),
      subtotal: parseDoubleSafely(json['subtotal']),
      description: json['description']?.toString() ?? '',
      isAddon: parseBoolSafely(json['is_addon']),
      isVeg: parseBoolSafely(json['is_veg']),
    );
  }
}