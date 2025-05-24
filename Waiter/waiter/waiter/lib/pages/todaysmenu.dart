import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:waiter/Controllers/api_service.dart';
import 'package:waiter/model/menuformenucart.dart';
import 'package:waiter/provider/cartprovider2.dart';
import 'package:waiter/ui/cartscreen2.dart';

class MenuScreen extends StatefulWidget {
  final int tableId;
  final String tableNumber;

  const MenuScreen({
    Key? key,
    required this.tableId,
    required this.tableNumber,
  }) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Category> _categories = [];
  MenuResponse _menuResponse = MenuResponse.empty();
  String _errorMessage = '';
  late TabController _tabController;
  final Map<int, List<MenuItem>> _itemsByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categoryResponse = await ApiService.fetchCategories();
      final menuResponse = await ApiService.fetchTodaysMenu();

      // Organize menu items by category
      final Map<int, List<MenuItem>> itemsByCategory = {};
      for (var menuItem in menuResponse.data) {
        if (menuItem.isActive && menuItem.availableQuantity > 0) {
          final categoryId = menuItem.item.categoryId;
          itemsByCategory.putIfAbsent(categoryId, () => []).add(menuItem);
        }
      }

      // Filter categories to only those with menu items
      final validCategories = categoryResponse.data
          .where((category) => itemsByCategory.containsKey(category.id))
          .toList();

      setState(() {
        _categories = validCategories;
        _menuResponse = menuResponse;
        _itemsByCategory.clear();
        _itemsByCategory.addAll(itemsByCategory);
        _isLoading = false;

        // Initialize tab controller after we have categories
        _tabController = TabController(
          length: _categories.length,
          vsync: this,
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber} - Menu',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                        tableId: widget.tableId,
                        tableNumber: widget.tableNumber,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (ctx, cart, child) => cart.itemCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ],
        bottom: _categories.isNotEmpty
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: _categories.map((category) {
                  return Tab(text: category.name.toUpperCase());
                }).toList(),
              )
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : _errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _menuResponse.data.isEmpty
                  ? Center(
                      child: Text('No menu items available today',
                          style: TextStyle(color: Colors.grey[600])))
                  : _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        final items = _itemsByCategory[category.id] ?? [];

        if (items.isEmpty) {
          return Center(
              child: Text('No items in this category',
                  style: TextStyle(color: Colors.grey[600])));
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          color: Colors.deepOrange,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _showAddToCartDialog(context, items[index]);
                },
                child: MenuItemCard(
                  menuItem: items[index],
                  tableId: widget.tableId,
                  tableNumber: widget.tableNumber,
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  void _showAddToCartDialog(BuildContext context, MenuItem menuItem) {
    int selectedQuantity = 1;
    String selectedSize = menuItem.item.quantities.isNotEmpty
        ? menuItem.item.quantities.first.quantityType
        : '';
    double selectedPrice = menuItem.item.quantities.isNotEmpty
        ? menuItem.item.quantities.first.prices.isNotEmpty
            ? menuItem.item.quantities.first.prices.first.price
            : 0.0
        : 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      menuItem.item.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (menuItem.item.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: menuItem.item.images.first.imagePath,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                                color: Colors.deepOrange),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    SizedBox(height: 16),

                    // Size Selection
                    if (menuItem.item.quantities.length > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Size:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: menuItem.item.quantities.map((quantity) {
                              // Get the first price for this quantity (assuming each quantity has at least one price)
                              final price = quantity.prices.isNotEmpty
                                  ? quantity.prices.first.price
                                  : 0.0;

                              return ChoiceChip(
                                label: Text(
                                  '${quantity.quantityType.toUpperCase()} - ₹${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: selectedSize == quantity.quantityType
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                selected: selectedSize == quantity.quantityType,
                                selectedColor: Colors.deepOrange,
                                backgroundColor: Colors.grey[200],
                                onSelected: (selected) {
                                  setState(() {
                                    selectedSize = quantity.quantityType;
                                    selectedPrice = price;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),

                    // Quantity Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: Colors.deepOrange),
                              onPressed: selectedQuantity > 1
                                  ? () => setState(() => selectedQuantity--)
                                  : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                selectedQuantity.toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: Colors.deepOrange),
                              onPressed:
                                  selectedQuantity < menuItem.availableQuantity
                                      ? () => setState(() => selectedQuantity++)
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '₹${(selectedPrice * selectedQuantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.deepOrange),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              final cartProvider = Provider.of<CartProvider>(
                                context,
                                listen: false,
                              );

                              // Add the item to cart with the selected quantity and price
                              cartProvider.addItem(
                                menuItem,
                                selectedSize,
                                quantity: selectedQuantity,
                                price: selectedPrice,
                              );

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added $selectedQuantity ${menuItem.item.name} to cart!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.deepOrange,
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CartScreen(
                                            tableId: widget.tableId,
                                            tableNumber: widget.tableNumber,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'ADD TO CART',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final int tableId;
  final String tableNumber;

  const MenuItemCard({
    Key? key,
    required this.menuItem,
    required this.tableId,
    required this.tableNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemDetail = menuItem.item;
    final lowestPrice = itemDetail.quantities.fold(
      double.infinity,
      (prev, quantity) => quantity.price < prev ? quantity.price : prev,
    );
    final highestPrice = itemDetail.quantities.fold(
      0.0,
      (prev, quantity) => quantity.price > prev ? quantity.price : prev,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemDetail.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: itemDetail.images.first.imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemDetail.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    if (itemDetail.isVeg)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child:
                            Icon(Icons.circle, color: Colors.green, size: 16),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Icon(Icons.circle, color: Colors.red, size: 16),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  itemDetail.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      itemDetail.quantities.length > 1
                          ? '₹${lowestPrice.toStringAsFixed(2)} - ₹${highestPrice.toStringAsFixed(2)}'
                          : '₹${lowestPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Text(
                      'Available: ${menuItem.availableQuantity}',
                      style: TextStyle(
                        color: menuItem.availableQuantity > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
