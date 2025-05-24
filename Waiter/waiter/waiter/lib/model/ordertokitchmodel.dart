class Order {
  final int id;
  final String orderId;
  final int restaurantId;
  final int guestCount;
  final String orderedBy;
  final int createdBy;
  final User? user;
  final String status;
  final double totalPrice;
  final String orderType;
  final String? remarks;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderTable> tables;

  Order({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.guestCount,
    required this.orderedBy,
    required this.createdBy,
    this.user,
    required this.status,
    required this.totalPrice,
    required this.orderType,
    this.remarks,
    required this.createdAt,
    required this.items,
    required this.tables,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderId: json['order_id'],
      restaurantId: json['restaurant_id'],
      guestCount: json['guest_count'],
      orderedBy: json['ordered_by'],
      createdBy: json['created_by'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      status: json['status'],
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      orderType: json['order_type'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      items: List<OrderItem>.from(
          json['items']?.map((x) => OrderItem.fromJson(x)) ?? []),
      tables: List<OrderTable>.from(
          json['tables']?.map((x) => OrderTable.fromJson(x)) ?? []),
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantityType: json['quantity_type'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      totalQuantity: json['total_quantity'],
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      description: json['description'],
      isAddon: json['is_addon'] ?? false,
      isVeg: json['is_veg'] ?? false,
    );
  }
}

class OrderTable {
  final int id;
  final int restaurantId;
  final String tableNumber;
  final int chair;
  final String? positionCode;
  final int seatsUsed;
  final bool isAc;
  final bool isActive;

  OrderTable({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.chair,
    this.positionCode,
    required this.seatsUsed,
    required this.isAc,
    required this.isActive,
  });

  factory OrderTable.fromJson(Map<String, dynamic> json) {
    return OrderTable(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      tableNumber: json['table_number'],
      chair: json['chair'],
      positionCode: json['position_code'],
      seatsUsed: json['seats_used'],
      isAc: json['is_ac'] ?? false,
      isActive: json['is_active'] ?? false,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      vendorId: json['vendor_id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
      imagePath: json['image_path'],
      role: json['role'],
    );
  }
}
