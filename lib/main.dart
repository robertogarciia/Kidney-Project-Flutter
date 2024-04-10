import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/login_page.dart';

import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),

      );
  }
}
