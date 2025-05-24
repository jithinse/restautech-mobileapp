


import 'package:flutter/material.dart';

import 'package:waiterapr04/views/home/widgets/app_drawer.dart';
import 'package:waiterapr04/views/home/widgets/order_card.dart';
import 'package:waiterapr04/views/home/widgets/order_details_sheet.dart';
import 'package:waiterapr04/views/home/widgets/order_stats.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Stream<List<Order>> _ordersStream;
  String _errorMessage = '';
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _ordersStream = _apiService.getOrdersStream();
  }

  // Function to sort orders by status priority
  List<Order> _getSortedOrders(List<Order> orders) {
    // Define the priority order (highest to lowest)
    final statusPriority = {
      'served': 5,
      'ready': 4,
      'preparing': 3,
      'pending': 2,
      'completed': 1,
      // Default priority for any other status
      'default': 0,
    };

    // Create a copy of the orders list to avoid modifying the original
    final sortedOrders = List<Order>.from(orders);

    // Sort based on the priority map
    sortedOrders.sort((a, b) {
      int priorityA = statusPriority[a.status.toLowerCase()] ?? statusPriority['default']!;
      int priorityB = statusPriority[b.status.toLowerCase()] ?? statusPriority['default']!;

      // Sort in descending order (higher priority first)
      return priorityB.compareTo(priorityA);
    });

    return sortedOrders;
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersStream = _apiService.getOrdersStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => HomeController().logout(context),
          ),
        ],
      ),
      drawer: AppDrawer(user: widget.user),
      body: StreamBuilder<List<Order>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData && _isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          _isInitialLoading = false;
          final orders = snapshot.data!;
          return _buildOrderList(orders);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders: $error',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshOrders,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshOrders,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    // Get sorted orders for display
    final sortedOrders = _getSortedOrders(orders);

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[50]!, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            OrderStats(orders: orders),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                return OrderCard(
                  order: sortedOrders[index],
                  onTap: () => _showOrderDetails(sortedOrders[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.deepOrange.withOpacity(0.1),
        ),
        child: Row(
          children: [
            const Icon(Icons.waving_hand, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Text(
              'Welcome, ${widget.user.name}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderDetailsSheet(
        order: order,
        onStatusUpdated: _refreshOrders,
      ),
    );
  }
}