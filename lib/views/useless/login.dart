// // ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'homepage.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[600],
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     width: 350,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: Form(
//                       key: formKey,
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Center(
//                                 child: Text(
//                                   "LOGIN",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 30,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey[700]),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             child: TextFormField(
//                               controller: emailController,
//                               decoration: const InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: "Email/Username",
//                               ),
//                               validator: loginUserNameValidation,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             child: TextFormField(
//                               controller: passwordController,
//                               validator: loginPassValidation,
//                               decoration: const InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: "Password",
//                               ),
//                               obscureText: true,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                               onChanged: (value) {},
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width,
//                             height: 64,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 formKey.currentState!.save();
//                                 if (formKey.currentState!.validate()) {
//                                   //
//                                   signin(context, emailController.text,
//                                       passwordController.text, "");
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     const Color.fromARGB(255, 255, 66, 66),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               child: const Text(
//                                 "Login",
//                                 style: TextStyle(fontSize: 18),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// String? loginPassValidation(value) {
//   if (value!.isEmpty) {
//     return 'Enter password';
//   } else if (value.length < 8) {
//     return 'Password must be at least 8 characters';
//   } else if (!RegExp(r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
//       .hasMatch(value)) {
//     return 'Password should have at atleast 1 letter, 1 number, 1 special character';
//   }
//   return null;
// }

// String? loginUserNameValidation(value) {
//   if (value!.isEmpty) {
//     return 'Enter Username';
//   } else if (value.length < 5) {
//     return 'Enter the valid Username';
//   }
//   return null;
// }

// void signin(BuildContext context, String email, String password,
//     String userName) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: password);
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const Homepage(),
//         ));
//     // addToDatabase(email, userName);
//   } catch (e) {
//     debugPrint("Error: $e");
//     String errorMessage =
//         "An error occurred while signing in. Please check your email and password and try again.";
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Sign in failed"),
//           content: Text(errorMessage),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
