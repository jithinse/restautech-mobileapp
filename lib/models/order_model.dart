

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderResponse {
  final String message;
  final List<Order> data;

  OrderResponse({
    required this.message,
    required this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final orders = (json['data'] as List?)?.map((item) => Order.fromJson(item)).toList() ?? [];

    orders.sort((a, b) {
      final statusOrder = {
        'pending': 1,
        'preparing': 2,
        'ready': 3,
        'completed': 4,
      };

      final aStatus = statusOrder[a.status] ?? 5;
      final bStatus = statusOrder[b.status] ?? 5;

      if (aStatus != bStatus) {
        return aStatus.compareTo(bStatus);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return OrderResponse(
      message: json['message'] ?? '',
      data: orders,
    );
  }
}

class Order {
  final int id;
  final String orderId;
  final String status;
  final DateTime createdAt;
  final Table table;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.table,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      table: Table.fromJson(json['table'] ?? {}),
      items: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
    );
  }

  String get formattedTime {
    return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'preparing': return Colors.blue;
      case 'ready': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

class Table {
  final String tableNumber;

  Table({
    required this.tableNumber,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      tableNumber: json['table_number']?.toString() ?? '0',
    );
  }
}

class OrderItem {
  final String name;
  final String category;
  final int totalQuantity;
  final String quantityType;
  final bool isVeg;

  OrderItem({
    required this.name,
    required this.category,
    required this.totalQuantity,
    required this.quantityType,
    required this.isVeg,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      totalQuantity: json['total_quantity'] ?? 0,
      quantityType: json['quantity_type'] ?? 'piece',
      isVeg: json['is_veg'] ?? false,
    );
  }

  String get quantityDisplay {
    switch (quantityType) {
      case 'piece': return '$totalQuantity pc(s)';
      case 'weight': return '$totalQuantity g';
      case 'liter': return '$totalQuantity L';
      case 'half': return '$totalQuantity half';
      case 'quarter': return '$totalQuantity quarter';
      case 'full': return '$totalQuantity full';
      default: return '$totalQuantity';
    }
  }

  IconData get vegNonVegIcon {
    return isVeg ? Icons.grass : Icons.set_meal;
  }

  Color get vegNonVegColor {
    return isVeg ? Colors.green : Colors.red;
  }
}