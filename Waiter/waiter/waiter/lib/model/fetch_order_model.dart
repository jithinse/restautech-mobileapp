// fetch_order_model.dart
import 'package:flutter/foundation.dart';

class FetchOrderModel {
  final String message;
  final List<OrderData> data;

  FetchOrderModel({
    required this.message,
    required this.data,
  });

  factory FetchOrderModel.fromJson(Map<String, dynamic> json) {
    return FetchOrderModel(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((item) => OrderData.fromJson(item))
          .toList(),
    );
  }
}

class OrderData {
  final int id;
  final String orderId;
  final int restaurantId;
  final int guestCount;
  final String orderedBy;
  final int createdBy;
  final User user;
  final String status;
  final String? paymentMethod;
  final double totalPrice;
  final String orderType;
  final String? remarks;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderTable> tables;

  OrderData({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.guestCount,
    required this.orderedBy,
    required this.createdBy,
    required this.user,
    required this.status,
    this.paymentMethod,
    required this.totalPrice,
    required this.orderType,
    this.remarks,
    required this.createdAt,
    required this.items,
    required this.tables,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      guestCount: json['guest_count'] ?? 0,
      orderedBy: json['ordered_by'] ?? '',
      createdBy: json['created_by'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'],
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      orderType: json['order_type'] ?? '',
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      tables: (json['tables'] as List<dynamic>)
          .map((table) => OrderTable.fromJson(table))
          .toList(),
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
  }

  String get tablesInfo {
    return tables.map((table) => table.tableNumber).join(', ');
  }

  String get itemsSummary {
    return items.map((item) => '${item.name} (x${item.totalQuantity})').join(', ');
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
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['country_code'] ?? '',
      phone: json['phone'] ?? '',
      imagePath: json['image_path'] ?? '',
      role: json['role'] ?? '',
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantityType: json['quantity_type'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0.0'),
      totalQuantity: json['total_quantity'] ?? 0,
      subtotal: double.parse(json['subtotal']?.toString() ?? '0.0'),
      description: json['description'] ?? '',
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
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      tableNumber: json['table_number'] ?? '',
      chair: json['chair'] ?? 0,
      positionCode: json['position_code'],
      seatsUsed: json['seats_used'] ?? 0,
      isAc: json['is_ac'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }
}