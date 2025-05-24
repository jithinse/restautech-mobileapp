class Quantity {
  final int id;
  final int restaurantId;
  final int itemId;
  final String quantityType;
  final String value;
  final bool isActive;

  Quantity({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    required this.quantityType,
    required this.value,
    required this.isActive,
  });

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      itemId: json['item_id'],
      quantityType: json['quantity_type'],
      value: json['value'],
      isActive: json['is_active'],
    );
  }
}
