import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';


class OrderDialog extends StatelessWidget {
  final Order order;
  final Color statusColor;
  final bool isHighPriority;
  final String formattedTime;
  final VoidCallback onStatusChange;

  const OrderDialog({
    Key? key,
    required this.order,
    required this.statusColor,
    required this.isHighPriority,
    required this.formattedTime,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, minHeight: 200, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildStatusRow(),
            const Divider(height: 8),
            _buildItemsList(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu, size: 24, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Table ${order.table.tableNumber} - Order #${order.orderId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          _buildTimeBadge(),
        ],
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighPriority ? Colors.red.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighPriority) const Icon(Icons.alarm, color: Colors.red, size: 16),
          if (isHighPriority) const SizedBox(width: 6),
          Text(
            formattedTime,
            style: TextStyle(
              color: isHighPriority ? Colors.red : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: statusColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            'Status: ${order.status.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case 'pending': return Icons.fiber_new;
      case 'preparing': return Icons.restaurant;
      case 'ready': return Icons.check_circle;
      case 'completed': return Icons.done_all;
      default: return Icons.info;
    }
  }

  Widget _buildItemsList() {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => _buildItemCard(item)).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Veg/Non-veg indicator
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: item.isVeg ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isVeg ? Icons.circle : Icons.circle,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Quantity
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${item.totalQuantity} ${item.quantityType}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }




//new


  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (order.status.toLowerCase() == 'pending')
            _buildActionButton(
              context,
              'Start Preparing',
              Colors.blue,
              Icons.restaurant,
              'preparing',
            )
          else if (order.status.toLowerCase() == 'preparing')
            _buildActionButton(
              context,
              'Mark as Ready',
              Colors.green,
              Icons.check_circle,
              'ready',
            )
          else if (order.status.toLowerCase() == 'ready')
              _buildActionButton(
                context,
                'Mark as Served', // Changed text
                Colors.orange, // Changed color
                Icons.room_service, // Changed icon
                'served', // Changed status
              ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      Color color,
      IconData icon,
      String newStatus,
      ) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          final apiService = ApiService();
          final response = await apiService.updateOrderStatus(order.id!, newStatus);

          Navigator.of(context).pop();

          if (response.statusCode == 200) {
            Navigator.of(context).pop();
            onStatusChange();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order marked as served')), // Updated message
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update status: ${response.statusCode}')),
            );
          }
        } catch (e) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: ${e.toString()}')),
          );
        }
      },
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

}