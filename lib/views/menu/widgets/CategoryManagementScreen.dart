import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/category_model.dart';
import 'category_management_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  _CategoryManagementScreenState createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _apiService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteCategory(Category category) async {
    final confirmed = await _showDeleteConfirmationDialog(category);
    if (!confirmed) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _apiService.deleteCategory(category.id);
      setState(() {
        _categories.removeWhere((c) => c.id == category.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<bool> _showDeleteConfirmationDialog(Category category) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
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
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Center(
        child: CategoryManagementDialog(
          categories: _categories,
          isLoading: _isLoading || _isDeleting,
          onDeleteCategory: _handleDeleteCategory,
        ),
      ),
    );
  }
}