import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/pages/login_page.dart';

class DadesPersonals extends StatelessWidget {
  const DadesPersonals({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Row( // Usar Row en lugar de Center
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:  Color(0xA6403DF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    // Texto "Dades Personals"
                    Text(
                      "Dades Personals",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox( height: 30 ),
    
  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
