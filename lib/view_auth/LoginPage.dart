// import 'package:fat_app/auth/auth_service.dart';
// import 'package:fat_app/constants/routes.dart';
// import 'package:fat_app/ultilities/Show_Error_Dialog.dart';
// import 'package:fat_app/firebase_options.dart';
// import 'package:fat_app/view/loading/LoadingView.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _email;
//   late final TextEditingController _password;

//   @override
//   void initState() {
//     super.initState();
//     _email = TextEditingController();
//     _password = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: FutureBuilder(
//         future: Firebase.initializeApp(
//           options: DefaultFirebaseOptions.currentPlatform,
//         ),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Form(
//               key: _formKey,
//               child: ListView(
//                 padding: const EdgeInsets.all(16.0),
//                 children: [
//                   TextFormField(
//                     controller: _email,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(),
//                     ),
//                     enableSuggestions: true,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _password,
//                     enableSuggestions: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         try {
//                           await AuthServices.firebase(context).logIn(
//                               email: _email.text, password: _password.text);
//                           final user =
//                               AuthServices.firebase(context).currentUser;
//                           if (user?.isEmailVerified ?? false) {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     LoadingView(duration: 3000),
//                               ),
//                             );
//                             // Navigator.of(context).pushNamedAndRemoveUntil(
//                             //   interactlearningpage,
//                             //   (route) => false,
//                             //   arguments: {
//                             //     'email': _email,
//                             //   },
//                             // );
//                           } else {
//                             Navigator.of(context).pushNamedAndRemoveUntil(
//                                 emailverifyRoute, (route) => false);
//                           }
//                         } catch (e) {
//                           await Show_Error_Dialog(
//                               context, 'Failed to login: ${e.toString()}');
//                         }
//                       }
//                     },
//                     child: const Text('Login'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pushNamedAndRemoveUntil(
//                           registerRoutes, (route) => false);
//                     },
//                     child: const Text('Not registered yet? Register here'),
//                   ),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
