import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiter/Controllers/api_service.dart';
import 'package:waiter/provider/cartprovider2.dart';

import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  final int tableId;
  final String tableNumber;

  const CartScreen({
    Key? key,
    required this.tableId,
    required this.tableNumber,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _guestCountController =
      TextEditingController(text: '1');
  bool _isSubmitting = false;
  String? _orderType = 'dine_in';
  bool _isCheckingApiConnection = false;
  @override
  void dispose() {
    _remarksController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    setState(() => _isCheckingApiConnection = true);

    try {
      final result = await ApiService.checkApiConnection();
      if (!result['success']) {
        if (mounted) {
          // Show a more detailed error message
          final message = result['message'] ?? 'API connection failed';
          final redirectLocation = result['redirect_location'] ?? '';
          final detailedMessage = redirectLocation.isNotEmpty
              ? '$message\nRedirect detected to: $redirectLocation'
              : message;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(detailedMessage),
              duration: Duration(seconds: 10),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () {
                  // Show more technical details in a dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('API Connection Details'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current API URL:'),
                            SizedBox(height: 4),
                            Text(
                              ApiConstants.baseUrl,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            if (redirectLocation.isNotEmpty) ...[
                              Text('Redirect Target:'),
                              SizedBox(height: 4),
                              Text(
                                redirectLocation,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 12),
                            ],
                            Text('Troubleshooting Tips:'),
                            SizedBox(height: 4),
                            Text('1. Verify the API URL in constants.dart'),
                            Text('2. Check if the server uses URL rewriting'),
                            Text('3. Ensure endpoint paths are correct'),
                            Text('4. Check server configuration'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking API connection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to API: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingApiConnection = false);
      }
    }
  }

  // Future<void> _submitOrder() async {
  //   if (_isSubmitting) return;
  //
  //   setState(() => _isSubmitting = true);
  //   final cartProvider = Provider.of<CartProvider>(context, listen: false);
  //
  //   try {
  //     print('🛒 Preparing order items...');
  //     final orderItems = cartProvider.items.map((item) {
  //       // Make sure quantity_id is an integer
  //       final quantityId = item.selectedSize is String
  //           ? int.tryParse(item.selectedSize) ?? 1
  //           : item.selectedSize;
  //
  //       final data = {
  //         'item_id': item.menuItem.item.id,
  //         'quantity_id': quantityId, // Ensure it's a proper integer
  //         'total_quantity': item.quantity,
  //       };
  //       print('➡️ Item: $data');
  //       return data;
  //     }).toList();
  //
  //     print('🍽️ Preparing table info...');
  //     final tables = _orderType == 'dine_in'
  //         ? [
  //       {
  //         'table_id': widget.tableId,
  //         'seats_used': int.tryParse(_guestCountController.text) ?? 1,
  //       }
  //     ]
  //         : [];
  //
  //     print('📝 Tables: $tables');
  //
  //     final requestBody = {
  //       'order_type': _orderType,
  //       'remarks': _remarksController.text.trim(),
  //       'order_items': orderItems,
  //       'tables': tables,
  //     };
  //
  //     print('📦 Request Body: ${json.encode(requestBody)}');
  //
  //     // Before sending, let's log detailed information about the request
  //     print('🔍 Detailed order items:');
  //     for (int i = 0; i < orderItems.length; i++) {
  //       final item = orderItems[i];
  //       print('Item $i:');
  //       print('  - item_id: ${item['item_id']} (${item['item_id'].runtimeType})');
  //       print('  - quantity_id: ${item['quantity_id']} (${item['quantity_id'].runtimeType})');
  //       print('  - total_quantity: ${item['total_quantity']} (${item['total_quantity'].runtimeType})');
  //     }
  //
  //     // Use the improved createOrder method
  //     final result = await ApiService.createOrder(requestBody);
  //
  //     if (result['success']) {
  //       print('✅ Order created successfully! Order ID: ${result['data']?['id']}');
  //
  //       cartProvider.clear();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['message'] ?? 'Order created successfully!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //
  //       // Navigation to payment screen would go here
  //       // Navigator.of(context).pushReplacement(...);
  //
  //     } else {
  //       print('❌ API Error: ${result['message']}');
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(result['message'] ?? 'Failed to create order'),
  //           backgroundColor: Colors.red,
  //           duration: Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('🔥 Exception occurred: $e');
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error creating order: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 5),
  //       ),
  //     );
  //   } finally {
  //     print('🔚 Order submission finished.');
  //     if (mounted) {
  //       setState(() => _isSubmitting = false);
  //     }
  //   }
  // }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      print('🛒 Preparing order items...');
      final orderItems = cartProvider.items.map((item) {
        // Important: Use the priceId from the CartItem instead of selectedSize
        // This ensures we're sending the correct quantity_id that belongs to this item
        final data = {
          'item_id': item.menuItem.item.id,
          'quantity_id': item
              .priceId, // Use priceId which should be the correct ID for this item's size
          'total_quantity': item.quantity,
        };
        print('➡️ Item: $data');
        return data;
      }).toList();

      print('🍽️ Preparing table info...');
      final tables = _orderType == 'dine_in'
          ? [
              {
                'table_id': widget.tableId,
                'seats_used': int.tryParse(_guestCountController.text) ?? 1,
              }
            ]
          : [];

      print('📝 Tables: $tables');

      final requestBody = {
        'order_type': _orderType,
        'remarks': _remarksController.text.trim(),
        'order_items': orderItems,
        'tables': tables,
      };

      print('📦 Request Body: ${json.encode(requestBody)}');

      // Before sending, let's log detailed information about the request
      print('🔍 Detailed order items:');
      for (int i = 0; i < orderItems.length; i++) {
        final item = orderItems[i];
        print('Item $i:');
        print(
            '  - item_id: ${item['item_id']} (${item['item_id'].runtimeType})');
        print(
            '  - quantity_id: ${item['quantity_id']} (${item['quantity_id'].runtimeType})');
        print(
            '  - total_quantity: ${item['total_quantity']} (${item['total_quantity'].runtimeType})');
      }

      // Use the improved createOrder method
      final result = await ApiService.createOrder(requestBody);

      if (result['success']) {
        print(
            '✅ Order created successfully! Order ID: ${result['data']?['id']}');

        cartProvider.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Order created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the menu or to a confirmation screen
          Navigator.of(context).pop();
        }
      } else {
        print('❌ API Error: ${result['message']}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to create order'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('🔥 Exception occurred: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      print('🔚 Order submission finished.');
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber} - Order Summary'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Type Selection
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Type',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Dine In'),
                                value: 'dine_in',
                                groupValue: _orderType,
                                onChanged: (value) =>
                                    setState(() => _orderType = value),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Take Away'),
                                value: 'take_away',
                                groupValue: _orderType,
                                onChanged: (value) =>
                                    setState(() => _orderType = value),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Guest Count
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guest Count',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _guestCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Number of guests',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Order Items
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Items',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        cartProvider.items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: cartProvider.items.length,
                                itemBuilder: (context, index) {
                                  final item = cartProvider.items[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.menuItem.item.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${item.selectedSize} - ₹${item.selectedPrice.toStringAsFixed(2)} x ${item.quantity}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Item controls
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  Icons.remove_circle_outline),
                                              onPressed: () => cartProvider
                                                  .decrementQuantity(index),
                                              color: Colors.deepOrange,
                                            ),
                                            Text('${item.quantity}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            IconButton(
                                              icon: Icon(
                                                  Icons.add_circle_outline),
                                              onPressed: () => cartProvider
                                                  .incrementQuantity(index),
                                              color: Colors.deepOrange,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '₹${item.totalPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => cartProvider
                                              .removeItemByObject(item),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),

                // Remarks
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Special Instructions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _remarksController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Any special requests or instructions...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Order Summary
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:',
                                style: TextStyle(fontSize: 16)),
                            Text(
                              '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (5%):',
                                style: TextStyle(fontSize: 16)),
                            Text(
                              '₹${(cartProvider.totalAmount * 0.05).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '₹${(cartProvider.totalAmount * 1.05).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: cartProvider.items.isEmpty || _isSubmitting
                    ? null
                    : _submitOrder,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'PROCEED TO CHECKOUT',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
