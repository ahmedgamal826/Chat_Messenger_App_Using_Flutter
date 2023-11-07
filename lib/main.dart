// import 'package:chat_messenger_app/pages/register_page.dart';
// import 'package:chat_messenger_app/services/auth/login_or_register.dart';
//import 'dart:js';

import 'package:chat_messenger_app/firebase_options.dart';
import 'package:chat_messenger_app/services/auth/auth_service.dart';
import 'package:chat_messenger_app/services/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
