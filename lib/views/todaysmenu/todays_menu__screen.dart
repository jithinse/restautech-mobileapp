


import 'package:flutter/material.dart';
import 'package:waiterapr04/views/todaysmenu/widgets/menu_item_detail_dailoguebox.dart';

import '../../models/category_model.dart';
import '../../models/menu_add_model.dart';
import '../../models/menu_item_model.dart';
import '../../services/api_service.dart';

class TodaysMenuScreen extends StatefulWidget {
  const TodaysMenuScreen({Key? key}) : super(key: key);

  @override
  State<TodaysMenuScreen> createState() => _TodaysMenuScreenState();
}

class _TodaysMenuScreenState extends State<TodaysMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<TodaysMenuItem> _todaysMenuItems = [];
  List<MenuItem> _availableMenuItems = [];
  List<TodaysMenuItem> _filteredTodaysMenuItems = [];
  List<MenuItem> _filteredAvailableMenuItems = [];
  List<Category> _categories = []; // Store all categories
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterMenuItems);
    _loadData();
  }

  void _filterMenuItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTodaysMenuItems = List.from(_todaysMenuItems);
        _filteredAvailableMenuItems = List.from(_availableMenuItems);
      } else {
        _filteredTodaysMenuItems = _todaysMenuItems
            .where((item) =>
        item.item?.name.toLowerCase().contains(query) ?? false)
            .toList();
        _filteredAvailableMenuItems = _availableMenuItems
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load categories first
      _categories = await _apiService.fetchCategories();
      print('Loaded ${_categories.length} categories');

      // Load today's menu
      final todaysMenuResponse = await _apiService.fetchTodaysMenu();
      print('Loaded today\'s menu with ${todaysMenuResponse.data.length} items');

      // Load all menu items for the "Add Menu" tab
      final allMenuItems = <MenuItem>[];

      for (final category in _categories) {
        print('Loading menu items for category: ${category.id} - ${category.name}');
        final menuItems = await _apiService.fetchMenuItemsByCategory(category.id);
        print('  Found ${menuItems.length} items in category ${category.name}');
        allMenuItems.addAll(menuItems);
      }

      // Get a list of menu items that are already in today's menu
      final existingMenuItemIds = todaysMenuResponse.data
          .where((item) => item.item != null)
          .map((item) => item.itemId)
          .toSet();
      print('Today\'s menu contains ${existingMenuItemIds.length} items');

      // Filter out menu items already in today's menu
      final availableMenuItems = allMenuItems
          .where((item) => !existingMenuItemIds.contains(item.id))
          .toList();
      print('${availableMenuItems.length} menu items available to add');

      setState(() {
        _todaysMenuItems = todaysMenuResponse.data;
        _availableMenuItems = availableMenuItems;
        _filteredTodaysMenuItems = List.from(_todaysMenuItems);
        _filteredAvailableMenuItems = List.from(_availableMenuItems);
        _isLoading = false;
      });
    } catch (e) {
      print('Error while loading data: $e');
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }



  Future<void> _addToTodaysMenu(MenuItem menuItem) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      print('Attempting to add menu item ${menuItem.id} - ${menuItem.name} to today\'s menu');

      final result = await _apiService.addToTodaysMenu(menuItem.id);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${menuItem.name} added to today\'s menu'),
            backgroundColor: Colors.green,
          ),
        );
        // Load only today's menu items without affecting _availableMenuItems
        _loadTodaysMenuOnly();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${menuItem.name} to today\'s menu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception in _addToTodaysMenu: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadTodaysMenuOnly() async {
    try {
      // Load today's menu
      final todaysMenuResponse = await _apiService.fetchTodaysMenu();
      print('Loaded today\'s menu with ${todaysMenuResponse.data.length} items');

      setState(() {
        _todaysMenuItems = todaysMenuResponse.data;
        _filteredTodaysMenuItems = List.from(_todaysMenuItems);
      });
    } catch (e) {
      print('Error while loading today\'s menu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading today\'s menu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }





  Future<void> _removeFromTodaysMenu(TodaysMenuItem todaysMenuItem) async {
    // Show confirmation dialog
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Today\'s Menu'),
        content: Text(
            'Are you sure you want to remove "${todaysMenuItem.item?.name}" from today\'s menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldRemove) {
      try {
        setState(() {
          _isLoading = true;
        });

        final result = await _apiService.removeFromTodaysMenu(todaysMenuItem.id);

        setState(() {
          _isLoading = false;
        });

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed from today\'s menu')),
          );
          // Only reload today's menu items
          _loadTodaysMenuOnly();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove item from today\'s menu')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // Also dispose search controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Menu Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(85.0), // Height for TabBar + Search
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'TODAY\'S MENU'),
                  Tab(text: 'ADD MENU ITEM'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : TabBarView(
        controller: _tabController,
        children: [
          // Today's Menu Tab
          _buildTodaysMenuTab(),

          // Add Menu Item Tab
          _buildAddMenuItemTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Modified to group items by category
  Widget _buildTodaysMenuTab() {
    if (_filteredTodaysMenuItems.isEmpty) {
      return const Center(
        child: Text(
            'No items in today\'s menu. Add some from the "ADD MENU ITEM" tab.'),
      );
    }

    // Group menu items by category
    final groupedItems = <int, List<TodaysMenuItem>>{};

    for (final todaysMenuItem in _filteredTodaysMenuItems) {
      // Skip items with null item or invalid category IDs
      if (todaysMenuItem.item == null) {
        continue;
      }

      final categoryId = todaysMenuItem.item!.categoryId;

      if (!_isValidCategory(categoryId)) {
        continue;
      }

      if (!groupedItems.containsKey(categoryId)) {
        groupedItems[categoryId] = [];
      }

      groupedItems[categoryId]!.add(todaysMenuItem);
    }

    // Create a list of categories with their menu items
    final categoryIds = groupedItems.keys.toList()
      ..sort((a, b) {
        final catA = _getCategoryName(a);
        final catB = _getCategoryName(b);
        return catA.compareTo(catB);
      });

    return ListView.builder(
      itemCount: categoryIds.length,
      itemBuilder: (context, index) {
        final categoryId = categoryIds[index];
        final menuItems = groupedItems[categoryId]!;
        final categoryName = _getCategoryName(categoryId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            ...menuItems.map((todaysMenuItem) {
              final menuItem = todaysMenuItem.item!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => MenuItemDetailDialog(menuItem: menuItem),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: menuItem.images.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        menuItem.images.first.imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                      ),
                    )
                        : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
                    title: Text(
                      menuItem.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          menuItem.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8, // Space between widgets
                          children: [
                            // Display the item price
                            Text(
                              _getItemPriceDisplay(menuItem),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            // Display availability
                            if (todaysMenuItem.availableQuantity != null)
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 6, vertical: 2),
                              //   decoration: BoxDecoration(
                              //     color: Colors.blue.shade100,
                              //     borderRadius: BorderRadius.circular(4),
                              //   ),
                              //   child: Text(
                              //     'Avl: ${todaysMenuItem.availableQuantity}',
                              //     style: TextStyle(
                              //       fontSize: 12,
                              //       color: Colors.blue.shade800,
                              //     ),
                              //   ),
                              // ),
                            // Veg/Non-veg indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: menuItem.isVeg
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                menuItem.isVeg ? 'VEG' : 'NON-VEG',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: menuItem.isVeg
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromTodaysMenu(todaysMenuItem),
                    ),
                  ),
                ),
              );
            }).toList(),
            const Divider(height: 32, thickness: 1),
          ],
        );
      },
    );
  }



  Widget _buildAddMenuItemTab() {
    if (_filteredAvailableMenuItems.isEmpty) {
      return const Center(
        child: Text('All menu items are already in today\'s menu!'),
      );
    }

    // Remove duplicate items by ID
    final uniqueMenuItemsMap = <int, MenuItem>{};
    for (final item in _filteredAvailableMenuItems) {
      uniqueMenuItemsMap[item.id] = item; // This keeps only the last instance per ID
    }
    final uniqueMenuItems = uniqueMenuItemsMap.values.toList();

    // Group menu items by category
    final groupedItems = <int, List<MenuItem>>{};
    for (final menuItem in uniqueMenuItems) {
      final categoryId = menuItem.categoryId;

      // Skip items with invalid category IDs
      if (!_isValidCategory(categoryId)) {
        print('Skipping item with invalid category ID: $categoryId');
        continue;
      }

      groupedItems.putIfAbsent(categoryId, () => []);
      groupedItems[categoryId]!.add(menuItem);
    }

    // Sort category IDs by name
    final categoryIds = groupedItems.keys.toList()
      ..sort((a, b) => _getCategoryName(a).compareTo(_getCategoryName(b)));

    print('Found ${categoryIds.length} valid categories to display');

    return ListView.builder(
      itemCount: categoryIds.length,
      itemBuilder: (context, index) {
        final categoryId = categoryIds[index];
        final menuItems = groupedItems[categoryId]!;
        final categoryName = _getCategoryName(categoryId);

        print('Building category section: $categoryId - $categoryName with ${menuItems.length} items');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            ...menuItems.map((menuItem) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => MenuItemDetailDialog(menuItem: menuItem),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: menuItem.images.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      menuItem.images.first.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                  title: Text(
                    menuItem.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        menuItem.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          // Text(
                          //   _getItemPriceDisplay(menuItem),
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.deepOrange,
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: menuItem.isVeg ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              menuItem.isVeg ? 'VEG' : 'NON-VEG',
                              style: TextStyle(
                                fontSize: 12,
                                color: menuItem.isVeg ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => _addToTodaysMenu(menuItem),
                  ),
                ),
              ),
            )),
            const Divider(height: 32, thickness: 1),
          ],
        );
      },
    );
  }


  // Check if category ID is valid
  bool _isValidCategory(int categoryId) {
    return _categories.any((category) => category.id == categoryId);
  }

  // Updated method to get category name by id
  String _getCategoryName(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return "Unknown Category";
  }



  String _getItemPriceDisplay(MenuItem menuItem) {
    // Debug prices
    print('Checking price for ${menuItem.name}:');
    print(' - Direct price: ${menuItem.price}');
    if (menuItem.quantities.isNotEmpty && menuItem.quantities.first.prices.isNotEmpty) {
      print(' - First quantity price: ${menuItem.quantities.first.prices.first.price}');
    }

    // Use the direct price property first if it's valid
    if (menuItem.price > 0) {
      return '\$${menuItem.price.toStringAsFixed(2)}';
    }

    // Fallback to quantities if direct price is zero or invalid
    if (menuItem.quantities.isNotEmpty) {
      for (var quantity in menuItem.quantities) {
        if (quantity.prices.isNotEmpty) {
          final price = quantity.prices.first.price;
          if (price > 0) {
            return '\$${price.toStringAsFixed(2)}';
          }
        }
      }
    }

    // Default price if nothing else works
    return '\$0.00';
  }
}