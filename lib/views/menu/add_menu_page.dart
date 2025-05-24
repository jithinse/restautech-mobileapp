


import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import '../../../services/api_service.dart';
import 'widgets/menu_drawer.dart';
import 'widgets/category_section.dart';
import 'widgets/menu_item_section.dart';
import 'widgets/menu_item_list.dart';
import 'widgets/category_management_dialog.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({Key? key}) : super(key: key);

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _apiService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  void _showCategoryManagementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoryManagementDialog(
          categories: _categories,
          isLoading: _isLoading,
          onDeleteCategory: _deleteCategory,
        );
      },
    );
  }

  Future<void> _deleteCategory(Category category) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Close the dialog
    Navigator.of(context).pop();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        );
      },
    );

    try {
      final success = await _apiService.deleteCategory(category.id);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Reload categories
        await _loadCategories();

        // If the deleted category was selected, clear selection
        if (_selectedCategory?.id == category.id) {
          setState(() {
            _selectedCategory = null;
          });
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reopen category management dialog
        _showCategoryManagementDialog();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete category. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );

        // Reopen category management dialog
        _showCategoryManagementDialog();
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Reopen category management dialog
      _showCategoryManagementDialog();
    }
  }

  void _updateSelectedCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<bool> _addCategory(String categoryName) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        );
      },
    );

    try {
      final success = await _apiService.addCategory(categoryName);

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Reload categories to get the newly added one
        await _loadCategories();

        // Find the newly added category
        final newCategory = _categories.firstWhere(
              (cat) => cat.name == categoryName,
          orElse: () => _categories.first,
        );

        setState(() {
          _selectedCategory = newCategory;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add category. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCategories,
            tooltip: 'Refresh Categories',
          ),
        ],
      ),
      drawer: MenuDrawer(
        onManageCategories: _showCategoryManagementDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Section
              CategorySection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategoryChanged: _updateSelectedCategory,
                onAddCategory: _addCategory,
              ),

              const SizedBox(height: 24),

              // Menu Item Section - Only show when a category is selected
              if (_selectedCategory != null)
                MenuItemSection(
                  selectedCategory: _selectedCategory,
                ),

              const SizedBox(height: 24),

              // Menu Item List Section - Will only show items for the selected category
              MenuItemList(
                selectedCategory: _selectedCategory,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_isLoading && _errorMessage == null
          ? FloatingActionButton(
        onPressed: _showCategoryManagementDialog,
        backgroundColor: Colors.deepOrange,
        tooltip: 'Manage Categories',
        child: const Icon(Icons.category, color: Colors.white),
      )
          : null,
    );
  }
}