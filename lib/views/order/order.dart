import 'order_item.dart';

class Order {
  final String id;
  final int tableNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  bool isCompleted;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.isCompleted = false,
  });
}
