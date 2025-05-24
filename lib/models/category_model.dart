class Category {
  final int id;
  final int restaurantId;
  final String name;
  final String? description;
  final String? imagePath;
  final bool isActive;

  Category({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.imagePath,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      isActive: json['is_active'],
    );
  }
}

class CategoryResponse {
  final String message;
  final List<Category> data;

  CategoryResponse({
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      message: json['message'],
      data: (json['data'] as List).map((item) => Category.fromJson(item)).toList(),
    );
  }
}