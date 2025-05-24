// import 'package:flutter/material.dart';


// class TableCard extends StatelessWidget {
//   final Table table;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const TableCard({
//     super.key,
//     required this.table,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Table #${table.tableNumber}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.chair, size: 16),
//                 const SizedBox(width: 8),
//                 Text('${table.chairCount} Chairs'),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.ac_unit,
//                   size: 16,
//                   color: table.isAc ? Colors.blue : Colors.grey,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(table.isAc ? 'AC Table' : 'Non-AC Table'),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: onDelete,
//                   child: const Text(
//                     'Delete',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: onEdit,
//                   child: const Text('Edit'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }