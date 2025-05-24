

class MenuItem {
  final int id;
  final String name;
  final int restaurantId;
  final int categoryId;
  final String description;
  final bool isVeg;
  final bool isAddon;
  final bool isActive;
  final double price; // This will be the first available price from quantities
  final List<MenuItemQuantity> quantities;
  final List<MenuItemImage> images;
  final MenuItemCategory? category;

  MenuItem({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.categoryId,
    required this.description,
    required this.isVeg,
    required this.isAddon,
    required this.isActive,
    required this.price,
    required this.quantities,
    this.images = const [],
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Parse quantities from JSON
    List<MenuItemQuantity> quantitiesList = [];
    if (json['quantities'] != null) {
      if (json['quantities'] is Map) {
        json['quantities'].forEach((key, value) {
          quantitiesList.add(MenuItemQuantity.fromJson(key, value));
        });
      } else if (json['quantities'] is List) {
        quantitiesList = (json['quantities'] as List)
            .map((item) => MenuItemQuantity.fromJson('', item))
            .toList();
      }
    }

    // Parse images from JSON
    List<MenuItemImage> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((item) => MenuItemImage.fromJson(item))
          .toList();
    }

    // Parse category from JSON
    MenuItemCategory? categoryObj;
    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      categoryObj = MenuItemCategory.fromJson(json['category']);
    }

    // Calculate the price - take the first available price from quantities
    double calculatedPrice = 0.0;
    if (quantitiesList.isNotEmpty && quantitiesList[0].prices.isNotEmpty) {
      calculatedPrice = quantitiesList[0].prices[0].price;
      print('Setting price for item ${json['name']}: $calculatedPrice');
    } else {
      print('No price found for item ${json['name']}, defaulting to 0.0');
    }

    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      description: json['description']?.toString() ?? '',
      isVeg: json['is_veg'] ?? false,
      isAddon: json['is_addon'] ?? false,
      isActive: json['is_active'] ?? true,
      price: calculatedPrice,
      quantities: quantitiesList,
      images: imagesList,
      category: categoryObj,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> quantitiesMap = {};
    for (var quantity in quantities) {
      quantitiesMap[quantity.quantityType] = quantity.toJson();
    }

    return {
      'id': id,
      'name': name,
      'restaurant_id': restaurantId,
      'category_id': categoryId,
      'description': description,
      'is_veg': isVeg,
      'is_addon': isAddon,
      'is_active': isActive,
      'price': price,
      'quantities': quantitiesMap,
      'images': images.map((img) => img.toJson()).toList(),
      'category': category?.toJson(),
    };
  }
}

class MenuItemQuantity {
  final String quantityType;
  final String value;
  final List<MenuItemPrice> prices;

  MenuItemQuantity({
    required this.quantityType,
    required this.value,
    required this.prices,
  });

  factory MenuItemQuantity.fromJson(String type, dynamic json) {
    List<MenuItemPrice> pricesList = [];

    if (json is Map && json['prices'] != null && json['prices'] is List) {
      pricesList = (json['prices'] as List)
          .map((item) => MenuItemPrice.fromJson(item))
          .toList();
    } else if (json is Map && json['price'] != null) {
      // If there's just a single price field
      pricesList.add(MenuItemPrice(price: double.tryParse(json['price'].toString()) ?? 0.0));
    }

    return MenuItemQuantity(
      quantityType: type,
      value: json is Map ? json['value']?.toString() ?? '' : '',
      prices: pricesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'prices': prices.map((price) => price.toJson()).toList(),
    };
  }
}

class MenuItemPrice {
  final double price;

  MenuItemPrice({
    required this.price,
  });

  factory MenuItemPrice.fromJson(Map<String, dynamic> json) {
    return MenuItemPrice(
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
    };
  }
}

class MenuItemImage {
  final String imagePath;

  MenuItemImage({
    required this.imagePath,
  });

  factory MenuItemImage.fromJson(Map<String, dynamic> json) {
    return MenuItemImage(
      imagePath: json['image_path']?.toString() ?? json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
    };
  }
}

class MenuItemCategory {
  final int id;
  final String name;

  MenuItemCategory({
    required this.id,
    required this.name,
  });

  factory MenuItemCategory.fromJson(Map<String, dynamic> json) {
    return MenuItemCategory(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}