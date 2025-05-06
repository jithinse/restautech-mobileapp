import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../../../services/api_service.dart';


class OrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;
  final VoidCallback onTap;
  final bool isHighPriority;
  final String formattedTime;

  const OrderCard({
    Key? key,
    required this.order,
    required this.statusColor,
    required this.onTap,
    required this.isHighPriority,
    required this.formattedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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
  }




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
}