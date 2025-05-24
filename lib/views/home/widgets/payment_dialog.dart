import 'package:flutter/material.dart';

import '../../../models/order_model.dart';


class PaymentDialog extends StatelessWidget {
  final Order order;

  const PaymentDialog({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Payment'),
      content: Text('Confirm payment of \$${order.totalPrice.toStringAsFixed(2)} for Order #${order.orderId}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _processPayment(context),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) async {
    Navigator.pop(context); // Close payment dialog
    Navigator.pop(context); // Close order details

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of \$${order.totalPrice.toStringAsFixed(2)} successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}