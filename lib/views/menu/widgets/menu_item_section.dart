//
//
// import 'package:flutter/material.dart';
// import '../../../models/category_model.dart';
// import '../../../services/api_service.dart';
//
// class MenuItemSection extends StatefulWidget {
//   final Category? selectedCategory;
//
//   const MenuItemSection({
//     Key? key,
//     required this.selectedCategory,
//   }) : super(key: key);
//
//   @override
//   State<MenuItemSection> createState() => _MenuItemSectionState();
// }
//
// class _MenuItemSectionState extends State<MenuItemSection> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _itemNameController = TextEditingController();
//   // Removed the base price controller since we'll only use quantity prices
//   final TextEditingController _itemDescriptionController = TextEditingController();
//   final ApiService _apiService = ApiService();
//   bool _isVeg = false;
//   bool _isLoading = false;
//
//   // Updated list of valid quantity types based on the API validation error
//   final List<String> _quantityTypes = ['piece', 'gram', 'kilogram', 'liter', 'milliliter', 'plate', 'box', 'serving'];
//
//   // Quantity options management with quantity_type and value added
//   // Set the initial quantity_type to a valid value from the list
//   final Map<String, Map<String, dynamic>> _quantities = {
//     'regular': {'price': 0.0, 'stock': 0, 'quantity_type': 'piece', 'value': 1},
//   };
//
//   @override
//   void dispose() {
//     _itemNameController.dispose();
//     // Removed disposal of the price controller
//     _itemDescriptionController.dispose();
//     super.dispose();
//   }
//
//   void _addQuantityOption() {
//     setState(() {
//       _quantities['size_${_quantities.length + 1}'] = {
//         'price': 0.0,
//         'stock': 0,
//         'quantity_type': 'piece', // Default quantity type from the valid list
//         'value': 1,
//       };
//     });
//   }
//
//   void _removeQuantityOption(String key) {
//     setState(() {
//       _quantities.remove(key);
//     });
//   }
//
//   void _updateQuantityOption(String key, String field, dynamic value) {
//     setState(() {
//       _quantities[key]![field] = value;
//     });
//   }
//
//   Future<void> _addMenuItem() async {
//     if (!_formKey.currentState!.validate() || widget.selectedCategory == null) {
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Validate quantity_type values before submitting
//       bool allQuantityTypesValid = true;
//       _quantities.forEach((key, value) {
//         if (!_quantityTypes.contains(value['quantity_type'])) {
//           allQuantityTypesValid = false;
//         }
//       });
//
//       if (!allQuantityTypesValid) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('One or more quantity types are invalid. Please check and retry.'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // Get the price from the first quantity option (regular)
//       double itemPrice = _quantities['regular']?['price'] ?? 0.0;
//
//       // Debug prints
//       debugPrint('Adding menu item with following details:');
//       debugPrint('Name: ${_itemNameController.text.trim()}');
//       debugPrint('Category ID: ${widget.selectedCategory!.id}');
//       debugPrint('Price: $itemPrice');
//       debugPrint('Description: ${_itemDescriptionController.text.trim()}');
//       debugPrint('Is Vegetarian: $_isVeg');
//       debugPrint('Quantities: $_quantities');
//
//       final success = await _apiService.addMenuItem(
//         name: _itemNameController.text.trim(),
//         categoryId: widget.selectedCategory!.id,
//         price: itemPrice, // Use the price from the regular quantity option
//         description: _itemDescriptionController.text.trim(),
//         isVeg: _isVeg,
//         quantities: _quantities,
//       );
//
//       if (success) {
//         debugPrint('Menu item added successfully');
//         // Clear the form
//         _itemNameController.clear();
//         _itemDescriptionController.clear();
//         setState(() {
//           _isVeg = false;
//           _quantities.clear();
//           _quantities['regular'] = {'price': 0.0, 'stock': 0, 'quantity_type': 'piece', 'value': 1};
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Menu item added successfully'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       } else {
//         debugPrint('Failed to add menu item');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to add menu item. Please try again.'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error adding menu item: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.restaurant_menu, color: Colors.deepOrange),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Menu Item Details',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (widget.selectedCategory != null) ...[
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         '(Adding to ${widget.selectedCategory!.name})',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                           fontStyle: FontStyle.italic,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const Divider(),
//               const SizedBox(height: 16),
//
//               // Item name field
//               const Text(
//                 'Item Name',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _itemNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter item name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter an item name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Item description field
//               const Text(
//                 'Description',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _itemDescriptionController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter item description',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
//                   ),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Quantity options section
//               const Text(
//                 'Quantity Options',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Card-based layout for quantity options
//               ..._quantities.entries.map((entry) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12.0),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Option name and delete button row
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 initialValue: entry.key,
//                                 decoration: InputDecoration(
//                                   labelText: 'Option Name',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 onChanged: (value) {
//                                   if (value.isEmpty) return;
//                                   final data = _quantities.remove(entry.key);
//                                   if (data != null) {
//                                     setState(() {
//                                       _quantities[value] = data;
//                                     });
//                                   }
//                                 },
//                               ),
//                             ),
//                             if (_quantities.length > 1)
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _removeQuantityOption(entry.key),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//
//                         // Price and Stock row
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 initialValue: entry.value['price'].toString(),
//                                 decoration: InputDecoration(
//                                   labelText: 'Price',
//                                   prefixText: '\$',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null || value.trim().isEmpty) {
//                                     return 'Please enter a price';
//                                   }
//                                   try {
//                                     double.parse(value);
//                                   } catch (e) {
//                                     return 'Please enter a valid price';
//                                   }
//                                   return null;
//                                 },
//                                 onChanged: (value) {
//                                   _updateQuantityOption(
//                                     entry.key,
//                                     'price',
//                                     double.tryParse(value) ?? 0.0,
//                                   );
//                                   // Debug print when price changes
//                                   debugPrint('Price updated for ${entry.key}: ${double.tryParse(value) ?? 0.0}');
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: TextFormField(
//                                 initialValue: entry.value['stock'].toString(),
//                                 decoration: InputDecoration(
//                                   labelText: 'Stock',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) {
//                                   _updateQuantityOption(
//                                     entry.key,
//                                     'stock',
//                                     int.tryParse(value) ?? 0,
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//
//                         // Quantity type and value row
//                         Row(
//                           children: [
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 value: _quantityTypes.contains(entry.value['quantity_type'])
//                                     ? entry.value['quantity_type'] as String
//                                     : _quantityTypes.first,
//                                 decoration: InputDecoration(
//                                   labelText: 'Unit Type',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 items: _quantityTypes.map((String type) {
//                                   return DropdownMenuItem<String>(
//                                     value: type,
//                                     child: Text(type, overflow: TextOverflow.ellipsis),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     _updateQuantityOption(
//                                       entry.key,
//                                       'quantity_type',
//                                       newValue,
//                                     );
//                                     // Debug print when quantity type changes
//                                     debugPrint('Quantity type updated for ${entry.key}: $newValue');
//                                   }
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: TextFormField(
//                                 initialValue: (entry.value['value'] ?? 1).toString(),
//                                 decoration: InputDecoration(
//                                   labelText: 'Quantity Value',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                                 onChanged: (value) {
//                                   _updateQuantityOption(
//                                     entry.key,
//                                     'value',
//                                     int.tryParse(value) ?? 1,
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//
//               ElevatedButton.icon(
//                 onPressed: _addQuantityOption,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Quantity Option'),
//               ),
//               const SizedBox(height: 16),
//
//               // Vegetarian toggle
//               Row(
//                 children: [
//                   Switch(
//                     value: _isVeg,
//                     onChanged: (value) {
//                       setState(() {
//                         _isVeg = value;
//                       });
//                     },
//                     activeColor: Colors.green,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Vegetarian Item',
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     Icons.eco,
//                     color: _isVeg ? Colors.green : Colors.grey,
//                     size: 20,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//
//               // Add item button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: widget.selectedCategory == null || _isLoading
//                       ? null
//                       : _addMenuItem,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepOrange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   )
//                       : const Text(
//                     'Add Menu Item',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//               if (widget.selectedCategory == null)
//                 const Padding(
//                   padding: EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     'Please select a category first',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import '../../../services/api_service.dart';

class MenuItemSection extends StatefulWidget {
  final Category? selectedCategory;

  const MenuItemSection({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<MenuItemSection> createState() => _MenuItemSectionState();
}

class _MenuItemSectionState extends State<MenuItemSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isVeg = false;
  bool _isLoading = false;

  // Updated list of valid quantity types based on your requirements
  final List<String> _quantityTypes = ['quarter', 'half', 'full', 'piece', 'weight', 'liter'];

  // Quantity options management with quantity_type and value
  final Map<String, Map<String, dynamic>> _quantities = {
    'regular': {'price': 0.0, 'stock': 0, 'quantity_type': 'piece', 'value': 1},
  };

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  void _addQuantityOption() {
    setState(() {
      _quantities['size_${_quantities.length + 1}'] = {
        'price': 0.0,
        'stock': 0,
        'quantity_type': 'piece', // Default quantity type
        'value': 1,
      };
    });
  }

  void _removeQuantityOption(String key) {
    setState(() {
      _quantities.remove(key);
    });
  }

  void _updateQuantityOption(String key, String field, dynamic value) {
    setState(() {
      _quantities[key]![field] = value;
    });
  }


  
  
  Future<void> _addMenuItem() async {
    if (!_formKey.currentState!.validate() || widget.selectedCategory == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert quantities to the format expected by the API
      List<Map<String, dynamic>> quantitiesList = _quantities.entries.map((entry) {
        return {
          'quantity_type': entry.value['quantity_type'],
          'value': entry.value['value'].toString(),
          'price': entry.value['price'],
          'stock': entry.value['stock'],
        };
      }).toList();

      // Get the first price as the base price (or calculate an average if needed)
      double basePrice = _quantities.isNotEmpty
          ? _quantities.values.first['price'] ?? 0.0
          : 0.0;

      debugPrint('Adding menu item with following details:');
      debugPrint('Name: ${_itemNameController.text.trim()}');
      debugPrint('Category ID: ${widget.selectedCategory!.id}');
      debugPrint('Description: ${_itemDescriptionController.text.trim()}');
      debugPrint('Is Vegetarian: $_isVeg');
      debugPrint('Base Price: $basePrice');
      debugPrint('Quantities: $quantitiesList');

      final success = await _apiService.addMenuItem(
        name: _itemNameController.text.trim(),
        categoryId: widget.selectedCategory!.id,
        description: _itemDescriptionController.text.trim(),
        isVeg: _isVeg,
        quantities: quantitiesList,
        price: basePrice, // Provide the base price
      );

      if (success) {
        debugPrint('Menu item added successfully');
        // Clear the form
        _itemNameController.clear();
        _itemDescriptionController.clear();
        setState(() {
          _isVeg = false;
          _quantities.clear();
          _quantities['regular'] = {'price': 0.0, 'stock': 0, 'quantity_type': 'piece', 'value': 1};
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu item added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('Failed to add menu item');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add menu item. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant_menu, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  const Text(
                    'Menu Item Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '(Adding to ${widget.selectedCategory!.name})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Item name field
              const Text(
                'Item Name',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  hintText: 'Enter item name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Item description field
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemDescriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter item description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity options section
              const Text(
                'Quantity Options',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Card-based layout for quantity options
              ..._quantities.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Option name and delete button row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.key,
                                decoration: InputDecoration(
                                  labelText: 'Option Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) return;
                                  final data = _quantities.remove(entry.key);
                                  if (data != null) {
                                    setState(() {
                                      _quantities[value] = data;
                                    });
                                  }
                                },
                              ),
                            ),
                            if (_quantities.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeQuantityOption(entry.key),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Price and Stock row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value['price'].toString(),
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a price';
                                  }
                                  try {
                                    double.parse(value);
                                  } catch (e) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _updateQuantityOption(
                                    entry.key,
                                    'price',
                                    double.tryParse(value) ?? 0.0,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value['stock'].toString(),
                                decoration: InputDecoration(
                                  labelText: 'Stock',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _updateQuantityOption(
                                    entry.key,
                                    'stock',
                                    int.tryParse(value) ?? 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quantity type and value row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: entry.value['quantity_type'] as String,
                                decoration: InputDecoration(
                                  labelText: 'Unit Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: _quantityTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    _updateQuantityOption(
                                      entry.key,
                                      'quantity_type',
                                      newValue,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: (entry.value['value'] ?? 1).toString(),
                                decoration: InputDecoration(
                                  labelText: 'Quantity Value',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _updateQuantityOption(
                                    entry.key,
                                    'value',
                                    int.tryParse(value) ?? 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              ElevatedButton.icon(
                onPressed: _addQuantityOption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Quantity Option'),
              ),
              const SizedBox(height: 16),

              // Vegetarian toggle
              Row(
                children: [
                  Switch(
                    value: _isVeg,
                    onChanged: (value) {
                      setState(() {
                        _isVeg = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vegetarian Item',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.eco,
                    color: _isVeg ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add item button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.selectedCategory == null || _isLoading
                      ? null
                      : _addMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : const Text(
                    'Add Menu Item',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              if (widget.selectedCategory == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Please select a category first',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}