// import 'package:flutter/material.dart';
// import '../../../models/user_model.dart';
//
// import 'todays_menu_dialog.dart';
//
// class AppDrawer extends StatelessWidget {
//   final UserModel user;
//
//   const AppDrawer({Key? key, required this.user}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             accountName: Text(user.name),
//             accountEmail: Text(user.email),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Text(
//                 user.name[0].toUpperCase(),
//                 style: const TextStyle(fontSize: 40),
//               ),
//             ),
//             decoration: const BoxDecoration(
//               color: Colors.deepOrange,
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profile'),
//             onTap: () => _showUserDetailsDialog(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.history),
//             title: const Text('Order History'),
//             onTap: () => Navigator.pop(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.restaurant_menu),
//             title: const Text("Today's Menu"),
//             onTap: () {
//               Navigator.pop(context);
//               showDialog(
//                 context: context,
//                 builder: (context) => TodaysMenuDialog(),
//               );
//             },
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showUserDetailsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('User Details'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Name: ${user.name}'),
//             const SizedBox(height: 8),
//             Text('Email: ${user.email}'),
//             if (user.phone != null) ...[
//               const SizedBox(height: 8),
//               Text('Phone: ${user.phone}'),
//             ],
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

import '../../menu/add_menu_page.dart';
import '../../todaysmenu/todays_menu__screen.dart';

import 'todays_menu_dialog.dart';


class AppDrawer extends StatelessWidget {
  final UserModel user;

  const AppDrawer({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => _showUserDetailsDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text("Today's Menu"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const TodaysMenuScreen(),
              );
            },
          ),
          // New menu management option
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text("Manage Menu"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMenuPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.name}'),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            if (user.phone != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${user.phone}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}