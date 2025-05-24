import 'package:flutter/material.dart';

import '../../../models/order_model.dart';


class OrderStats extends StatelessWidget {
  final List<Order> orders;

  const OrderStats({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;
    final parcelOrders = orders.where((o) => o.orderType == 'Parcel').length;
    final nonParcelOrders = orders.where((o) => o.orderType == 'Non Parcel').length;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Orders', totalOrders.toString(), Icons.receipt_long, Colors.deepPurple)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Parcel', parcelOrders.toString(), Icons.takeout_dining, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Non Parcel', nonParcelOrders.toString(), Icons.restaurant, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}