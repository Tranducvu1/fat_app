// import 'package:fat_app/view/live/live.dart';
// import 'package:flutter/material.dart';

// class LiveGramScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           margin: EdgeInsets.only(left: 10, right: 10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'LiveGram',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => jumToLivePage(context, isHost: true),
//                 child: Text("Start live"),
//               ),
//               ElevatedButton(
//                 onPressed: () => jumToLivePage(context, isHost: false),
//                 child: Text("Watch a live"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void jumToLivePage(BuildContext context, {required bool isHost}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LivePage(isHost: isHost),
//       ),
//     );
//   }
// }
