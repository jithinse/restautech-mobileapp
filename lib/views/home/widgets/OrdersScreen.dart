import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
import 'order_card.dart';
import 'order_dialog.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.fetchOrders();

      setState(() {
        orders = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: ${e.toString()}')),
      );
    }
  }

  // This is the method you would pass to each OrderCard
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        // Calculate status color and time formatting here
        Color statusColor = _getStatusColor(order.status);
        bool isHighPriority = _isHighPriority(order.createdAt);
        String formattedTime = _formatTime(order.createdAt);

        return OrderDialog(
          order: order,
          statusColor: statusColor,
          isHighPriority: isHighPriority,
          formattedTime: formattedTime,
          onStatusChange: _fetchOrders, // This refreshes the orders list
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          Color statusColor = _getStatusColor(order.status);
          bool isHighPriority = _isHighPriority(order.createdAt);
          String formattedTime = _formatTime(order.createdAt);

          return OrderCard(
            order: order,
            statusColor: statusColor,
            isHighPriority: isHighPriority,
            formattedTime: formattedTime,
            onTap: () => _showOrderDetails(order),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool _isHighPriority(DateTime createdAt) {
    // Logic to determine if order is high priority
    // For example, if it's more than 15 minutes old
    return DateTime.now().difference(createdAt).inMinutes > 15;
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}