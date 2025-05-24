// import 'package:flutter/material.dart';
// import '../../controllers/auth_controller.dart';
// import '../../utils/validators.dart';
// import '../../widgets/error_message.dart';
// import '../Widgets/custom_textfield.dart';
// import '../utils/constants.dart';
//
// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({Key? key}) : super(key: key);
//
//   @override
//   _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
// }
//
// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   // In your ForgotPasswordPage or similar widget
//   Future<void> _resetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
//
//       final result = await AuthController.forgotPassword(_emailController.text);
//
//       setState(() {
//         _isLoading = false;
//         if (result['success']) {
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(result['message'])),
//           );
//           // Optionally navigate back
//           Navigator.pop(context);
//         } else {
//           _errorMessage = result['message'];
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(UIConstants.cardPadding),
//           child: Card(
//             elevation: 8,
//             child: Padding(
//               padding: EdgeInsets.all(UIConstants.defaultPadding),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 20),
//                       const Icon(
//                         Icons.lock_reset,
//                         size: 50,
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Enter your email to receive password reset instructions',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 20),
//                       CustomTextField(
//                         controller: _emailController,
//                         labelText: 'Email',
//                         prefixIcon: Icons.email,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: Validators.validateEmail,
//                       ),
//                       if (_errorMessage != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: ErrorMessage(message: _errorMessage!),
//                         ),
//                       if (_successMessage != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Text(
//                             _successMessage!,
//                             style: const TextStyle(color: Colors.green),
//                           ),
//                         ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         height: UIConstants.buttonHeight,
//                         child: ElevatedButton(
//                           onPressed: _isLoading
//                               ? null
//                               : () {
//                                   if (_formKey.currentState!.validate()) {
//                                     _resetPassword();
//                                   }
//                                 },
//                           child: _isLoading
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : const Text('Reset Password', style: TextStyle(fontSize: 16)),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text('Back to Login'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }