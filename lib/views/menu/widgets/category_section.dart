import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class CategorySection extends StatefulWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category?) onCategoryChanged;
  final Future<bool> Function(String) onAddCategory;

  const CategorySection({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddCategory,
  }) : super(key: key);

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final TextEditingController _categoryNameController = TextEditingController();
  bool _isAddingCategory = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                const Icon(Icons.category, color: Colors.deepOrange),
                const SizedBox(width: 8),
                const Text(
                  'Menu Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_isAddingCategory)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepOrange),
                    onPressed: () {
                      setState(() {
                        _isAddingCategory = true;
                      });
                    },
                    tooltip: 'Add New Category',
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Category dropdown or text field
            if (widget.categories.isNotEmpty && !_isAddingCategory)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Category>(
                    isExpanded: true,
                    hint: const Text('Select Category'),
                    value: widget.selectedCategory,
                    onChanged: widget.onCategoryChanged,
                    items: widget.categories.map<DropdownMenuItem<Category>>((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ),
                ),
              ),

            if (_isAddingCategory)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Add category button or save/cancel buttons
            if (_isAddingCategory)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingCategory = false;
                        _categoryNameController.clear();
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: () async {
                      if (_categoryNameController.text.trim().isNotEmpty) {
                        final success = await widget.onAddCategory(_categoryNameController.text.trim());

                        if (success) {
                          setState(() {
                            _categoryNameController.clear();
                            _isAddingCategory = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Category'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}