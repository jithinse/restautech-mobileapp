// import 'package:flutter/material.dart';
// import '../utils/role_managmenet_utility.dart';
//
//
// class RoleBasedWidget extends StatelessWidget {
//   final String userRole;
//   final List<UserRole> allowedRoles;
//   final Widget child;
//   final Widget? fallback;
//
//   const RoleBasedWidget({
//     Key? key,
//     required this.userRole,
//     required this.allowedRoles,
//     required this.child,
//     this.fallback,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (RoleUtils.hasAnyRole(userRole, allowedRoles)) {
//       return child;
//     }
//     return fallback ?? Container();
//   }
// }
//
// // Usage example:
// // RoleBasedWidget(
// //   userRole: user.role,
// //   allowedRoles: [UserRole.admin, UserRole.vendor],
// //   child: AdminActionButton(),
// //   fallback: Text('You do not have permission to perform this action'),
// // )