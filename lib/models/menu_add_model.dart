

import '../models/menu_item_model.dart';

class TodaysMenuResponse {
  final String message;
  final List<TodaysMenuItem> data;

  TodaysMenuResponse({
    required this.message,
    required this.data,
  });

  factory TodaysMenuResponse.fromJson(Map<String, dynamic> json) {
    // Handle case when data might not be a list
    List<dynamic> dataList = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        dataList = json['data'] as List<dynamic>;
      } else if (json['data'] is Map) {
        // If data is a map for some reason, wrap it in a list
        dataList = [json['data']];
      }
    }

    return TodaysMenuResponse(
      message: json['message']?.toString() ?? '',
      data: dataList
          .map((item) => TodaysMenuItem.fromJson(item))
          .toList(),
    );
  }
}

class TodaysMenuItem {
  final int id;
  final int restaurantId;
  final int itemId;
  final MenuItem? item;
  final int? totalQuantity;
  final int? availableQuantity;
  final int? soldQuantity;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodaysMenuItem({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    this.item,
    this.totalQuantity,
    this.availableQuantity,
    this.soldQuantity,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory TodaysMenuItem.fromJson(Map<String, dynamic> json) {
    return TodaysMenuItem(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      item: json['item'] != null ? MenuItem.fromJson(json['item']) : null,
      totalQuantity: json['total_quantity'],
      availableQuantity: json['available_quantity'],
      soldQuantity: json['sold_quantity'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
}

class TodaysMenuAddRequest {
  final int itemId;
  final int? totalQuantity;
  final bool? isActive;

  TodaysMenuAddRequest({
    required this.itemId,
    this.totalQuantity = 30, // Default value
    this.isActive = true,    // Default value
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'item_id': itemId,
    };

    // Only include optional fields if they're specified
    if (totalQuantity != null) {
      data['total_quantity'] = totalQuantity;
    }

    if (isActive != null) {
      data['is_active'] = isActive;
    }

    return data;
  }
}

class TodaysMenuAddResponse {
  final String message;
  final TodaysMenuItem data;

  TodaysMenuAddResponse({
    required this.message,
    required this.data,
  });

  factory TodaysMenuAddResponse.fromJson(Map<String, dynamic> json) {
    return TodaysMenuAddResponse(
      message: json['message'] ?? '',
      data: TodaysMenuItem.fromJson(json['data']),
    );
  }
}