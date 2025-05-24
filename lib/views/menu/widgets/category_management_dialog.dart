//
//
//
// import 'package:flutter/material.dart';
// import '../../../models/category_model.dart';
//
// class CategoryManagementDialog extends StatelessWidget {
//   final List<Category> categories;
//   final bool isLoading;
//   final Function(Category) onDeleteCategory;
//
//   const CategoryManagementDialog({
//     Key? key,
//     required this.categories,
//     required this.isLoading,
//     required this.onDeleteCategory,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Row(
//         children: [
//           Icon(Icons.category, color: Colors.deepOrange),
//           SizedBox(width: 8),
//           Text('Manage Categories'),
//         ],
//       ),
//       content: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
//           : SizedBox(
//         width: double.maxFinite,
//         child: categories.isEmpty
//             ? const Center(child: Text('No categories found'))
//             : ListView.builder(
//           shrinkWrap: true,
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final category = categories[index];
//             return ListTile(
//               title: Text(category.name),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 onPressed: () => onDeleteCategory(category),
//               ),
//             );
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Close', style: TextStyle(color: Colors.deepOrange)),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import 'CategoryManagementScreen.dart';

class CategoryManagementDialog extends StatelessWidget {
  final List<Category> categories;
  final bool isLoading;
  final Function(Category) onDeleteCategory;

  const CategoryManagementDialog({
    Key? key,
    required this.categories,
    required this.isLoading,
    required this.onDeleteCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.category, color: Colors.deepOrange),
          const SizedBox(width: 8),
          const Text('Manage Categories'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.deepOrange),
            onPressed: () {
              // This will trigger a rebuild in the parent widget
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
            : categories.isEmpty
            ? const Center(child: Text('No categories found'))
            : ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  category.name,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDeleteCategory(category),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.deepOrange)),
        ),
      ],
    );
  }
}