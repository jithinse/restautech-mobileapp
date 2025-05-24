import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../../models/order_model.dart';
=======

import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5


class OrderCard extends StatelessWidget {
  final Order order;
<<<<<<< HEAD
  final VoidCallback onTap;
=======
  final Color statusColor;
  final VoidCallback onTap;
  final bool isHighPriority;
  final String formattedTime;
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5

  const OrderCard({
    Key? key,
    required this.order,
<<<<<<< HEAD
    required this.onTap,
=======
    required this.statusColor,
    required this.onTap,
    required this.isHighPriority,
    required this.formattedTime,
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isHighPriority
              ? const BorderSide(color: Colors.red, width: 2)
              : BorderSide.none,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildContent(),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, size: 22, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Table ${order.table.tableNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildTimeBadge(),
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Order #${order.orderId}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (order.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  order.items.length > 2
                      ? '${order.items[0].name}, ${order.items[1].name}, and more...'
                      : order.items.map((e) => e.name).join(', '),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFooter() {
  //   return Container(
  //     height: 60,
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Tap to view details',
  //           style: TextStyle(
  //             color: Colors.grey[600],
  //             fontSize: 12,
  //             fontStyle: FontStyle.italic,
  //           ),
  //         ),
  //         _buildActionButton(),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildFooter(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tap to view details',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          _buildActionButton(context), // Pass the context here
        ],
      ),
    );
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
  }



<<<<<<< HEAD
=======

  // Widget _buildActionButton() {
  //   if (order.status == 'pending') {
  //     return _buildButton('Start', Colors.blue);
  //   } else if (order.status == 'preparing') {
  //     return _buildButton('Ready', Colors.green);
  //   } else if (order.status == 'ready') {
  //     return _buildButton('Complete', Colors.grey);
  //   }
  //   return const SizedBox.shrink();
  // }
  //
  // Widget _buildButton(String text, Color color) {
  //   return SizedBox(
  //     height: 38,
  //     child: ElevatedButton(
  //       onPressed: () {},
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: color,
  //         foregroundColor: Colors.white,
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  //       ),
  //       child: Text(text, style: const TextStyle(fontSize: 14)),
  //     ),
  //   );
  // }

  //new

  // Widget _buildActionButton() {
  //   if (order.status == 'pending') {
  //     return _buildButton('Start', Colors.blue, 'preparing');
  //   } else if (order.status == 'preparing') {
  //     return _buildButton('Ready', Colors.green, 'ready');
  //   } else if (order.status == 'ready') {
  //     return _buildButton('Complete', Colors.grey, 'completed');
  //   }
  //   return const SizedBox.shrink();
  // }

  // Widget _buildActionButton(BuildContext context) {
  //   if (order.status == 'pending') {
  //     return _buildButton(context, 'Start', Colors.blue, 'preparing');
  //   } else if (order.status == 'preparing') {
  //     return _buildButton(context, 'Ready', Colors.green, 'ready');
  //   } else if (order.status == 'ready') {
  //     return _buildButton(context, 'Complete', Colors.grey, 'completed');
  //   }
  //   return const SizedBox.shrink();
  // }


  Widget _buildActionButton(BuildContext context) {
    if (order.status == 'pending') {
      return _buildButton(context, 'Start', Colors.blue, 'preparing');
    } else if (order.status == 'preparing') {
      return _buildButton(context, 'Ready', Colors.green, 'ready');
    } else if (order.status == 'ready') {
      return _buildButton(context, 'Mark as Served', Colors.orange, 'served'); // Changed to served
    }
    return const SizedBox.shrink();
  }


  Widget _buildButton(BuildContext context, String text, Color color, String newStatus) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: () async {
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            final apiService = ApiService();
            final response = await apiService.updateOrderStatus(order.id!, newStatus);

            Navigator.of(context).pop();

            if (response.statusCode == 200) {
              onTap();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order status updated to $newStatus')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update status: ${response.statusCode}')),
              );
            }
          } catch (e) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
}