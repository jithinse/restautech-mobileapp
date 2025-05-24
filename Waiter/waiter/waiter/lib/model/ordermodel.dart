class Order {
  final String orderNumber;
  final int tableNumber;
  final List<OrderItem> items;
  final int timer;
  final String status; // Status: New, In Progress, Completed

  Order({
    required this.orderNumber,
    required this.tableNumber,
    required this.items,
    required this.timer,
    required this.status,
  });

  // Copy method to create a new instance with updated fields
  Order copyWith({String? status}) {
    return Order(
      orderNumber: orderNumber,
      tableNumber: tableNumber,
      items: items,
      timer: timer,
      status: status ?? this.status,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final String instructions;

  OrderItem(
      {required this.name, required this.quantity, required this.instructions});
}
