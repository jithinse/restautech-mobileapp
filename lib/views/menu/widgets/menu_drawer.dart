import 'package:flutter/material.dart';

import 'CategoryManagementScreen.dart';




class MenuDrawer extends StatelessWidget {
  final VoidCallback onManageCategories;

  const MenuDrawer({
    Key? key,
    required this.onManageCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Restaurant Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.deepOrange),
            title: const Text('Add Menu Items'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),

          ListTile(
            leading: const Icon(Icons.category, color: Colors.deepOrange),
            title: const Text('Manage Categories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.deepOrange),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to settings page
            },
          ),
        ],
      ),
    );
  }
}