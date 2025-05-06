import 'menu_item.dart';

class OrderItem {
  final String id;
  final String name;
  final String type;
  int quantity;
  double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMenuItem(MenuItem item, {int quantity = 1, double? customPrice}) {
    return OrderItem(
      id: item.id,
      name: item.name,
      type: item.type,
      quantity: quantity,
      price: customPrice ?? item.defaultPrice,
    );
  }
}