

import 'dart:async';
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

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<OrderResponse> futureOrders;
  final ApiService apiService = ApiService();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Real-time update variables
  late Timer _orderRefreshTimer;
  List<Order> _currentOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _lastOrderCount = 0;

  // Settings for real-time updates
  final Duration _refreshInterval = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _loadOrders();

    // Start real-time updates
    _startAutoRefresh();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _orderRefreshTimer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Initial load
    _fetchOrdersRealtime();

    // Set up timer for regular updates
    _orderRefreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted) {
        _fetchOrdersRealtime();
      }
    });
  }

  Future<void> _fetchOrdersRealtime() async {
    if (!mounted) return;

    try {
      final orderResponse = await apiService.fetchOrders();

      // Check if there are new orders
      bool hasNewOrders = false;
      if (_currentOrders.isNotEmpty && orderResponse.data.length > _lastOrderCount) {
        hasNewOrders = true;
      }

      setState(() {
        _currentOrders = orderResponse.data;
        _lastOrderCount = _currentOrders.length;
        _isLoading = false;
        _errorMessage = null;
      });

      // Show notification if there are new orders
      if (hasNewOrders && mounted) {
        _showNewOrderNotification();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showNewOrderNotification() {
    // Show a snackbar when new orders arrive
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 10),
            Text('New orders have arrived!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Scroll to the top to see new orders
            // If you have a ScrollController, you could use it here
          },
        ),
      ),
    );
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      futureOrders = apiService.fetchOrders();
    });

    try {
      final orders = await futureOrders;
      setState(() {
        _currentOrders = orders.data;
        _lastOrderCount = _currentOrders.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _getTimeElapsedMinutes(Order order) {
    final DateTime now = DateTime.now();
    final DateTime createdAt = order.createdAt;
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
            onPressed: _fetchOrdersRealtime,
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
        onRefresh: _fetchOrdersRealtime,
        child: _buildOrdersView(),
      ),
    );
  }

  Widget _buildOrdersView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    } else if (_errorMessage != null) {
      return _buildErrorView();
    } else if (_currentOrders.isEmpty) {
      return _buildEmptyView();
    }

    final pendingOrders = _currentOrders.where((o) => o.status == 'pending').toList();
    final preparingOrders = _currentOrders.where((o) => o.status == 'preparing').toList();
    final readyOrders = _currentOrders.where((o) => o.status == 'ready').toList();
    final completedOrders = _currentOrders.where((o) => o.status == 'completed').toList();

    return _buildMainContent(
      pendingOrders,
      preparingOrders,
      readyOrders,
      completedOrders,
      _currentOrders.length,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Unable to load orders',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchOrdersRealtime,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          ),
        ],
      ),
    );
  }

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
        onStatusChange: _fetchOrdersRealtime,
      ),
    );
  }

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
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
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
}