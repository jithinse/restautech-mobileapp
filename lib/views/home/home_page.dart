


<<<<<<< HEAD
import 'package:flutter/material.dart';

import 'package:waiterapr04/views/home/widgets/app_drawer.dart';
import 'package:waiterapr04/views/home/widgets/order_card.dart';
import 'package:waiterapr04/views/home/widgets/order_details_sheet.dart';
import 'package:waiterapr04/views/home/widgets/order_stats.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'home_controller.dart';
=======



import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';
import '../auth/login_page.dart';
import 'widgets/nav_button.dart';
import 'widgets/stat_card.dart';
import 'widgets/status_section.dart';
import 'widgets/order_card.dart';
import 'widgets/order_dialog.dart';
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
<<<<<<< HEAD
  final ApiService _apiService = ApiService();
  late Stream<List<Order>> _ordersStream;
  String _errorMessage = '';
  bool _isInitialLoading = true;
=======
  late Future<OrderResponse> futureOrders;
  final ApiService apiService = ApiService();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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
=======
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      futureOrders = apiService.fetchOrders();
    });
  }

  int _getTimeElapsedMinutes(Order order) {
    final DateTime now = DateTime.now();
    final DateTime createdAt = order.createdAt ?? now;
    return now.difference(createdAt).inMinutes;
  }

  bool _isHighPriority(Order order) {
    return _getTimeElapsedMinutes(order) > 15;
  }






  Future<void> _logout() async {
    try {
      print('Attempting to logout...');
      final response = await apiService.logout();

      print('Logout response status code: ${response.statusCode}');

      // Handle 202 Accepted by waiting and retrying
      if (response.statusCode == 202) {
        await Future.delayed(const Duration(seconds: 1));
        return _logout(); // Retry
      }

      if (response.statusCode == 200 || response.statusCode == 302) {
        print('Logout successful, clearing token storage');
        await TokenStorage.clear();

        final token = await TokenStorage.getToken();
        print('Token after clear: $token');

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false
          );
        }
      } else {
        print('Logout failed with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }
  @override




  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Kitchen Display',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildUserDrawer(),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: _loadOrders,
        child: FutureBuilder<OrderResponse>(
          future: futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
            } else if (snapshot.hasError) {
              return _buildErrorView(snapshot);
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return _buildEmptyView();
            }

            final orders = snapshot.data?.data ?? [];
            final pendingOrders = orders.where((o) => o.status == 'pending').toList();
            final preparingOrders = orders.where((o) => o.status == 'preparing').toList();
            final readyOrders = orders.where((o) => o.status == 'ready').toList();
            final completedOrders = orders.where((o) => o.status == 'completed').toList();

            return _buildMainContent(
              pendingOrders,
              preparingOrders,
              readyOrders,
              completedOrders,
              orders.length,
            );
          },
        ),
      ),
    );
  }
  Widget _buildErrorView(AsyncSnapshot<OrderResponse> snapshot) {
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
<<<<<<< HEAD
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
=======
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Unable to load orders',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            '${snapshot.error}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildEmptyState() {
=======
  Widget _buildEmptyView() {
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
<<<<<<< HEAD
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
=======
          const Icon(Icons.restaurant, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Active Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'All caught up! New orders will appear here.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======



  Widget _buildMainContent(
      List<Order> pendingOrders,
      List<Order> preparingOrders,
      List<Order> readyOrders,
      List<Order> completedOrders,
      int totalOrders,
      ) {
    return Row(
      children: [
        // Side navigation
        Container(
          width: 80,
          color: Colors.grey[900],
          child: Column(
            children: [
              NavButton(
                label: 'All',
                icon: Icons.format_list_bulleted,
                count: totalOrders,
                onTap: () {},
              ),
              NavButton(
                label: 'New',
                icon: Icons.fiber_new,
                count: pendingOrders.length,
                color: Colors.amber,
                onTap: () {},
              ),
              NavButton(
                label: 'Prep',
                icon: Icons.restaurant,
                count: preparingOrders.length,
                color: Colors.blue,
                onTap: () {},
              ),
              NavButton(
                label: 'Ready',
                icon: Icons.check_circle,
                count: readyOrders.length,
                color: Colors.green,
                onTap: () {},
              ),
              NavButton(
                label: 'Done',
                icon: Icons.done_all,
                count: completedOrders.length,
                color: Colors.grey,
                onTap: () {},
              ),
              const Spacer(),
              NavButton(
                label: 'Help',
                icon: Icons.help_outline,
                onTap: () {},
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Order statistics bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    StatCard(title: 'New Orders', count: pendingOrders.length, color: Colors.amber),
                    StatCard(title: 'Preparing', count: preparingOrders.length, color: Colors.blue),
                    StatCard(title: 'Served', count: readyOrders.length, color: Colors.orange),
                    StatCard(title: 'Completed', count: completedOrders.length, color: Colors.grey),
                  ],
                ),
              ),
              // Orders display
              Expanded(
                child: ListView(
                  children: [
                    if (pendingOrders.isNotEmpty)
                      StatusSection(
                        title: 'New Orders',
                        orders: pendingOrders,
                        statusColor: Colors.amber,
                        icon: Icons.fiber_new,
                        onOrderTap: (order) => _showOrderDetails(context, order),
                      ),
                    if (preparingOrders.isNotEmpty)
                      StatusSection(
                        title: 'Preparing',
                        orders: preparingOrders,
                        statusColor: Colors.blue,
                        icon: Icons.restaurant,
                        onOrderTap: (order) => _showOrderDetails(context, order),
                      ),
                    if (readyOrders.isNotEmpty)
                      StatusSection(
                        title: 'Ready for Service',
                        orders: readyOrders,
                        statusColor: Colors.green,
                        icon: Icons.check_circle,
                        onOrderTap: (order) => _showOrderDetails(context, order),
                      ),
                    if (completedOrders.isNotEmpty)
                      StatusSection(
                        title: 'Completed',
                        orders: completedOrders,
                        statusColor: Colors.grey,
                        icon: Icons.done_all,
                        onOrderTap: (order) => _showOrderDetails(context, order),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }






  void _showOrderDetails(BuildContext context, Order order) {
    final isHighPriority = _isHighPriority(order);
    final formattedTime = _getTimeElapsedMinutes(order) > 0
        ? '${_getTimeElapsedMinutes(order)} min'
        : '${order.formattedTime}';
    final statusColor = _getStatusColor(order.status);

    showDialog(
      context: context,
      builder: (context) => OrderDialog(
        order: order,
        statusColor: statusColor,
        isHighPriority: isHighPriority,
        formattedTime: formattedTime,
        onStatusChange: _loadOrders,
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildUserDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name ?? 'User'),
            accountEmail: Text(widget.user.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.redAccent[700]),
            ),
            decoration: BoxDecoration(color: Colors.redAccent[700]),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              // Add profile navigation here
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.amber;
      case 'preparing': return Colors.blue;
      case 'ready': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Colors.grey;
    }
  }
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
}