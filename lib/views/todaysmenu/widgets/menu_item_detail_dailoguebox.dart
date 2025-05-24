import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';


class MenuItemDetailDialog extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemDetailDialog({
    Key? key,
    required this.menuItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item image
          if (menuItem.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                menuItem.images.first.imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        menuItem.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

                const SizedBox(height: 8),
                Text(
                  menuItem.category?.name ?? 'Unknown Category',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  menuItem.description,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Available Sizes & Prices',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Quantity and price list
                ...menuItem.quantities.map((quantity) {
                  final price = quantity.prices.isNotEmpty
                      ? quantity.prices.first.price
                      : null;

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${quantity.quantityType.toUpperCase()} (${quantity.value})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: price != null
                        ? Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    )
                        : const Text('Price N/A'),
                  );
                }).toList(),

                const SizedBox(height: 16),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}