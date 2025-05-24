


import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../services/api_service.dart';

class MenuItemList extends StatefulWidget {
  final Category? selectedCategory;

  const MenuItemList({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<MenuItemList> createState() => _MenuItemListState();
}

class _MenuItemListState extends State<MenuItemList> {
  final ApiService _apiService = ApiService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didUpdateWidget(MenuItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory?.id != oldWidget.selectedCategory?.id) {
      _loadMenuItems();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    if (widget.selectedCategory == null) {
      setState(() {
        _menuItems = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiService.fetchMenuItemsByCategory(widget.selectedCategory!.id);

      // Debug print to check the raw data
      print('Raw menu items data: $items');

      final filteredItems = items.where((item) =>
      item.categoryId == widget.selectedCategory!.id ||
          item.categoryId.toString() == widget.selectedCategory!.id.toString()
      ).toList();

      // Debug print to check filtered items and their prices
      print('Filtered ${filteredItems.length} items:');
      for (var item in filteredItems) {
        print('Item: ${item.name}, '
            'cPrice: ${item.price},'
            ' Quantities: ${item.quantities.length}');
        if (item.quantities.isNotEmpty && item.quantities[0].prices.isNotEmpty) {
          print('First quantity price: ${item.quantities[0].prices[0].price}');
        }
      }

      setState(() {
        _menuItems = filteredItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load menu items: $e';
        _isLoading = false;
      });
      print('Error loading menu items: $e');
    }
  }

  void _deleteMenuItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Here you would add the API call to delete the item
                // For example: await _apiService.deleteMenuItem(item.id);
                // After successful deletion, refresh the list
                _loadMenuItems();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCategory == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please select a category to view menu items',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.selectedCategory!.name} Menu Items',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadMenuItems,
                  tooltip: 'Refresh menu items',
                  color: Colors.deepOrange,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadMenuItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_menuItems.isEmpty)
                const Center(
                  child: Text(
                    'No menu items found in this category. Add your first item above!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                )
              else

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];

                    // Debug print to check prices
                    print('Item: ${item.name}');
                    print('Direct price: ${item.price}');
                    if (item.quantities.isNotEmpty && item.quantities[0].prices.isNotEmpty) {
                      print('Quantity price: ${item.quantities[0].prices[0].price}');
                    }

                    // Get the price - prioritize direct price, fall back to quantities
                    final price = item.price > 0 ? item.price :
                    (item.quantities.isNotEmpty &&
                        item.quantities[0].prices.isNotEmpty
                        ? item.quantities[0].prices[0].price
                        : 0.0);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isVeg ? Colors.green : Colors.deepOrange,
                          child: Icon(
                            item.isVeg ? Icons.eco : Icons.fastfood,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenuItem(item),
                              tooltip: 'Delete item',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}