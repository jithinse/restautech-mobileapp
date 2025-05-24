import 'package:flutter/material.dart';
import '../../../models/order_model.dart';

import 'order_card.dart';

class StatusSection extends StatelessWidget {
  final String title;
  final List<Order> orders;
  final Color statusColor;
  final IconData icon;
  final Function(Order) onOrderTap;

  const StatusSection({
    Key? key,
    required this.title,
    required this.orders,
    required this.statusColor,
    required this.icon,
    required this.onOrderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildOrderGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(icon, color: statusColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            orders.length.toString(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 2.2,
        mainAxisSpacing: 12,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isHighPriority = _isHighPriority(order);
        final formattedTime = _getFormattedTime(order);

        return OrderCard(
          order: order,
          statusColor: statusColor,
          onTap: () => onOrderTap(order),
          isHighPriority: isHighPriority,
          formattedTime: formattedTime,
        );
      },
    );
  }

  bool _isHighPriority(Order order) {
    final now = DateTime.now();
    final createdAt = order.createdAt ?? now;
    return now.difference(createdAt).inMinutes > 15;
  }

  String _getFormattedTime(Order order) {
    final now = DateTime.now();
    final createdAt = order.createdAt ?? now;
    final elapsedMinutes = now.difference(createdAt).inMinutes;
    return elapsedMinutes > 0 ? '$elapsedMinutes min' : '${order.formattedTime}';
  }
}