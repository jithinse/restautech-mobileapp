// menu_response.dart
class MenuResponse {
  final String message;
  final List<MenuItem> data;

  MenuResponse({required this.message, required this.data});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<MenuItem>.from(json['data'].map((x) => MenuItem.fromJson(x)))
          : [],
    );
  }

  factory MenuResponse.empty() {
    return MenuResponse(message: 'No data available', data: []);
  }
}

// menu_item.dart
class MenuItem {
  final int id;
  final int itemId;
  final ItemDetail item;
  final int restaurantId;
  final int totalQuantity;
  final int availableQuantity;
  final int soldQuantity;
  final bool isActive;

  MenuItem({
    required this.id,
    required this.itemId,
    required this.item,
    required this.restaurantId,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.soldQuantity,
    required this.isActive,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      item: ItemDetail.fromJson(json['item'] ?? {}),
      restaurantId: json['restaurant_id'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
      availableQuantity: json['available_quantity'] ?? 0,
      soldQuantity: json['sold_quantity'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}

// item_detail.dart
class ItemDetail {
  final int id;
  final String name;
  final int restaurantId;
  final int categoryId;
  final Category category;
  final String description;
  final bool isVeg;
  final bool isAddon;
  final bool isActive;
  final List<ItemImage> images;
  final List<ItemQuantity> quantities;

  ItemDetail({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.categoryId,
    required this.category,
    required this.description,
    required this.isVeg,
    required this.isAddon,
    required this.isActive,
    required this.images,
    required this.quantities,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      category: Category.fromJson(json['category'] ?? {}),
      description: json['description'] ?? '',
      isVeg: json['is_veg'] ?? false,
      isAddon: json['is_addon'] ?? false,
      isActive: json['is_active'] ?? false,
      images: json['images'] != null
          ? List<ItemImage>.from(
              json['images'].map((x) => ItemImage.fromJson(x)))
          : [],
      quantities: json['quantities'] != null
          ? List<ItemQuantity>.from(
              json['quantities'].map((x) => ItemQuantity.fromJson(x)))
          : [],
    );
  }
}

// category.dart
class Category {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String imagePath;
  final bool isActive;

  Category({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

// item_image.dart
class ItemImage {
  final int id;
  final int itemId;
  final String imagePath;
  final String? alt;

  ItemImage({
    required this.id,
    required this.itemId,
    required this.imagePath,
    this.alt,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      alt: json['alt'],
    );
  }
}

// item_quantity.dart
class ItemQuantity {
  final int id;
  final int restaurantId;
  final int itemId;
  final String quantityType;
  final String value;
  final bool isActive;
  final List<ItemPrice> prices;

  ItemQuantity({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    required this.quantityType,
    required this.value,
    required this.isActive,
    required this.prices,
  });

  factory ItemQuantity.fromJson(Map<String, dynamic> json) {
    return ItemQuantity(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      quantityType: json['quantity_type'] ?? '',
      value: json['value'] ?? '',
      isActive: json['is_active'] ?? false,
      prices: json['prices'] != null
          ? List<ItemPrice>.from(
              json['prices'].map((x) => ItemPrice.fromJson(x)))
          : [],
    );
  }

  double get price {
    return prices.isNotEmpty ? prices.first.price : 0.0;
  }
}

// item_price.dart
class ItemPrice {
  final int id;
  final int itemId;
  final int quantityId;
  final double price;
  final double? discount;
  final double? finalPrice;

  ItemPrice({
    required this.id,
    required this.itemId,
    required this.quantityId,
    required this.price,
    this.discount,
    this.finalPrice,
  });

  factory ItemPrice.fromJson(Map<String, dynamic> json) {
    return ItemPrice(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      quantityId: json['quantity_id'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discount: json['discount']?.toDouble(),
      finalPrice: json['final_price']?.toDouble(),
    );
  }
}

// category_response.dart
class CategoryResponse {
  final String message;
  final List<Category> data;

  CategoryResponse({required this.message, required this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<Category>.from(json['data'].map((x) => Category.fromJson(x)))
          : [],
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  final String selectedSize;
  final int quantity;
  final double selectedPrice;
  final int priceId;

  CartItem({
    required this.menuItem,
    required this.selectedSize,
    required this.quantity,
    required this.selectedPrice,
    required this.priceId,
  });

  // Deep copy with new values
  CartItem copyWith({
    MenuItem? menuItem,
    String? selectedSize,
    int? quantity,
    double? selectedPrice,
    int? priceId,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      selectedPrice: selectedPrice ?? this.selectedPrice,
      priceId: priceId ?? this.priceId,
    );
  }

  // Calculate total price for this item
  double get totalPrice => selectedPrice * quantity;
}
