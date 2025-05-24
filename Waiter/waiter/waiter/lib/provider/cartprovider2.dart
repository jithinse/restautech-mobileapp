import 'package:flutter/foundation.dart';
import 'package:waiter/model/menuformenucart.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Check if an item with the same menuItem and size is already in the cart
  bool isInCart(MenuItem menuItem, String size) {
    return _items.any((item) =>
        item.menuItem.item.id == menuItem.item.id && item.selectedSize == size);
  }

  // Add item to cart
  void addItem(
    MenuItem menuItem,
    String size, {
    required int quantity,
    required double price,
  }) {
    // Find the index of existing item with same menuItem and size
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menuItem.item.id == menuItem.item.id &&
          item.selectedSize == size,
    );

    // Find the quantity object that matches the selected size
    final selectedQuantity = menuItem.item.quantities.firstWhere(
      (q) => q.quantityType == size,
      orElse: () => throw Exception('Size not available'),
    );

    // Get the price ID (assuming we can use the first price)
    final priceId = selectedQuantity.prices.isNotEmpty
        ? selectedQuantity.prices.first.id
        : 0; // Default to 0 if no prices available

    if (existingIndex >= 0) {
      // Update existing item
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(
        CartItem(
          menuItem: menuItem,
          selectedSize: size,
          quantity: quantity,
          selectedPrice: price,
          priceId: priceId,
        ),
      );
    }
    notifyListeners();
  }

  // Increase quantity of item in cart
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      final currentItem = _items[index];
      if (currentItem.quantity < currentItem.menuItem.availableQuantity) {
        _items[index] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );
        notifyListeners();
      }
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      final currentItem = _items[index];
      if (currentItem.quantity > 1) {
        _items[index] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
        notifyListeners();
      } else {
        removeItem(index);
      }
    }
  }

  // Remove item from cart
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeItemByObject(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // Clear cart
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
