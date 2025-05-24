import 'package:flutter/material.dart';
import '../../../models/order_model.dart';


class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const Divider(),
              _buildOrderBadges(statusColor, statusIcon),
              const SizedBox(height: 12),
              _buildOrderSummary(),
              const SizedBox(height: 8),
              _buildItemsPreview(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${order.orderId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          order.formattedTime,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderBadges(Color statusColor, IconData statusIcon) {
    return Row(
      children: [
        _buildTableBadge(),
        const SizedBox(width: 8),
        _buildOrderTypeBadge(),
        const SizedBox(width: 8),
        _buildStatusBadge(statusColor, statusIcon),
      ],
    );
  }

  Widget _buildTableBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_bar, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            'Table ${order.table.tableNumber}',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeBadge() {
    final isParcel = order.orderType == 'Parcel';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isParcel ? Colors.teal[50] : Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isParcel ? Colors.teal[200]! : Colors.purple[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isParcel ? Icons.takeout_dining : Icons.restaurant,
            size: 16,
            color: isParcel ? Colors.teal : Colors.purple,
          ),
          const SizedBox(width: 4),
          Text(
            order.orderType,
            style: TextStyle(
              color: isParcel ? Colors.teal : Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            order.status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Text(
      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • \$${order.totalPrice.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildItemsPreview() {
    return Text(
      order.items.take(2).map((item) => item.name).join(', ') +
          (order.items.length > 2 ? ' and ${order.items.length - 2} more...' : ''),
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.visibility, size: 18),
          label: const Text('View Details'),
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepOrange,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.blue;
      case 'pending': return Colors.orange;
      case 'served': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'ready': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle;
      case 'pending': return Icons.pending;
      case 'processing': return Icons.hourglass_top;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }



}