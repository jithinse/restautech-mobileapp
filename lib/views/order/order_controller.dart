import 'package:flutter/material.dart';
import 'dart:math';

import 'menu_item.dart';
import 'order.dart';
import 'order_item.dart';

class OrderController extends ChangeNotifier {
  // Menu items data
  final List<MenuItem> _menuItems = [
    MenuItem(id: 'f1', name: 'Biryani', type: 'food', defaultPrice: 180),
    MenuItem(id: 'f2', name: 'Fried Rice', type: 'food', defaultPrice: 150),
    MenuItem(id: 'f3', name: 'Butter Naan', type: 'food', defaultPrice: 40),
    MenuItem(id: 'f4', name: 'Paneer Butter Masala', type: 'food', defaultPrice: 160),
    MenuItem(id: 'f5', name: 'Veg Manchurian', type: 'food', defaultPrice: 120),
    MenuItem(id: 'f6', name: 'Pizza', type: 'food', defaultPrice: 200),
    MenuItem(id: 'f7', name: 'Burger', type: 'food', defaultPrice: 120),
    MenuItem(id: 'f8', name: 'Pasta', type: 'food', defaultPrice: 160),
    MenuItem(id: 'f9', name: 'Dosa', type: 'food', defaultPrice: 100),
    MenuItem(id: 'f10', name: 'Idli Sambar', type: 'food', defaultPrice: 80),
    MenuItem(id: 'j1', name: 'Orange Juice', type: 'juice', defaultPrice: 60),
    MenuItem(id: 'j2', name: 'Mango Shake', type: 'juice', defaultPrice: 80),
    MenuItem(id: 'j3', name: 'Coffee', type: 'juice', defaultPrice: 40),
    MenuItem(id: 'j4', name: 'Lemonade', type: 'juice', defaultPrice: 50),
    MenuItem(id: 'j5', name: 'Lassi', type: 'juice', defaultPrice: 70),
    MenuItem(id: 'j6', name: 'Pepsi', type: 'juice', defaultPrice: 45),
    MenuItem(id: 'j7', name: 'Watermelon Juice', type: 'juice', defaultPrice: 65),
    MenuItem(id: 'j8', name: 'Iced Tea', type: 'juice', defaultPrice: 55),
    MenuItem(id: 'j9', name: 'Coconut Water', type: 'juice', defaultPrice: 50),
    MenuItem(id: 'j10', name: 'Milkshake', type: 'juice', defaultPrice: 85),
  ];

  // Table-specific order data - predefined orders for each table
  final Map<int, Map<String, int>> _tableOrders = {
    1: {'f1': 2, 'j4': 1}, // Table 1: 2 Biryani, 1 Lemonade
    2: {'f6': 1, 'j6': 2}, // Table 2: 1 Pizza, 2 Pepsi
    3: {'f2': 1, 'f3': 2, 'j1': 1}, // Table 3: 1 Fried Rice, 2 Butter Naan, 1 Orange Juice
    4: {'f4': 1, 'f3': 3, 'j2': 2}, // Table 4: 1 Paneer Butter Masala, 3 Butter Naan, 2 Mango Shake
    5: {'f5': 2, 'j3': 2}, // Table 5: 2 Veg Manchurian, 2 Coffee
    6: {'f7': 2, 'j5': 1}, // Table 6: 2 Burger, 1 Lassi
    7: {'f8': 1, 'j7': 2}, // Table 7: 1 Pasta, 2 Watermelon Juice
    8: {'f9': 2, 'j8': 3}, // Table 8: 2 Dosa, 3 Iced Tea
    9: {'f10': 4, 'j9': 4}, // Table 9: 4 Idli Sambar, 4 Coconut Water
    10: {'f1': 1, 'f6': 1, 'j10': 2}, // Table 10: 1 Biryani, 1 Pizza, 2 Milkshake
  };

  // Current order data
  Map<String, OrderItem> _currentOrderItems = {};
  int? _tableNumber;
  double _totalAmount = 0.0;

  // All orders
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];

  // Getters
  List<MenuItem> loadMenuItems({required String type}) {
    return _menuItems.where((item) => item.type == type).toList();
  }

  int getItemQuantity(MenuItem item) {
    return _currentOrderItems[item.id]?.quantity ?? 0;
  }

  double get totalAmount => _totalAmount;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get completedOrders => _completedOrders;

  bool hasItems() {
    return _currentOrderItems.isNotEmpty;
  }

  // Load predefined orders for a specific table
  void setTableNumber(int number) {
    _tableNumber = number;

    // Reset current order items
    _currentOrderItems = {};

    // Load predefined orders for this table
    if (_tableOrders.containsKey(number)) {
      Map<String, int> tableItems = _tableOrders[number]!;

      for (var entry in tableItems.entries) {
        String itemId = entry.key;
        int quantity = entry.value;

        // Find the menu item
        MenuItem? menuItem = _menuItems.firstWhere(
              (item) => item.id == itemId,
          orElse: () => null as MenuItem,
        );

        if (menuItem != null) {
          _currentOrderItems[itemId] = OrderItem(
            id: menuItem.id,
            name: menuItem.name,
            price: menuItem.defaultPrice,
            quantity: quantity,
            type: menuItem.type,
          );
        }
      }
    }

    // Calculate total for the loaded items
    calculateTotal();
    notifyListeners();
  }

  // New method to display all menu items at once
  void loadAllItemsForDisplay() {
    // This method is called when a table is selected
    notifyListeners();
  }

  // Methods
  void increaseQuantity(MenuItem item) {
    if (_currentOrderItems.containsKey(item.id)) {
      _currentOrderItems[item.id]!.quantity++;
    } else {
      _currentOrderItems[item.id] = OrderItem.fromMenuItem(item);
    }
    // Automatically recalculate total when adding items
    calculateTotal();
    notifyListeners();
  }

  void decreaseQuantity(MenuItem item) {
    if (_currentOrderItems.containsKey(item.id)) {
      if (_currentOrderItems[item.id]!.quantity > 1) {
        _currentOrderItems[item.id]!.quantity--;
      } else {
        _currentOrderItems.remove(item.id);
      }
      // Automatically recalculate total when removing items
      calculateTotal();
      notifyListeners();
    }
  }

  void updateItemPrice(MenuItem item, double price) {
    if (_currentOrderItems.containsKey(item.id)) {
      _currentOrderItems[item.id]!.price = price;
      // Automatically recalculate total when changing price
      calculateTotal();
      notifyListeners();
    }
  }

  void calculateTotal() {
    _totalAmount = 0;
    _currentOrderItems.forEach((key, item) {
      _totalAmount += (item.price * item.quantity);
    });
    notifyListeners();
  }

  void placeOrder() {
    if (_tableNumber != null && _currentOrderItems.isNotEmpty) {
      // Create a new order
      final order = Order(
        id: 'ORD${Random().nextInt(10000)}',
        tableNumber: _tableNumber!,
        items: _currentOrderItems.values.toList(),
        totalAmount: _totalAmount,
        createdAt: DateTime.now(),
      );

      // Add to active orders
      _activeOrders.add(order);

      // Reset current order
      _currentOrderItems = {};
      _totalAmount = 0;
      _tableNumber = null;

      notifyListeners();
    }
  }

  void completeOrder(Order order) {
    // Remove from active orders
    _activeOrders.remove(order);

    // Mark as completed and add to completed orders
    order.isCompleted = true;
    _completedOrders.add(order);

    notifyListeners();
  }
}