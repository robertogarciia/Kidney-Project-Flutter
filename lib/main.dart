import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/firebase_options.dart';
import 'package:kidneyproject/pages/login_page.dart';  
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:kidneyproject/pages/cestaPage.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';
import 'package:provider/provider.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => CestaProvider(), 
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), 
    );
  }
}
