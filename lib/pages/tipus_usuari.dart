import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';


class TipusUsuari extends StatelessWidget {
  const TipusUsuari({Key? key}) : super(key: key);

  void iniciS() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              //text inicia sessio
              const Text(
                "Tipus D'usuari",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'lib/images/logoKNP_WT.png',
                height: 300,
              ),

              const SizedBox( height: 30 ),
    

              const SizedBox( height: 15 ),
              btn_general(
                buttonText: "Pacient", 
                onTap: iniciS
                ),
              const SizedBox( height: 30 ),
              btn_general(
                buttonText: "Familiar", 
                onTap: iniciS
                ),
              const SizedBox( height: 30 ),
              btn_general(
                buttonText: "Encara no les vull introduïr", 
                onTap: iniciS
                ),
              const SizedBox( height: 15 ),       
            ],
          ),
        ),
      ),
    );
  }
}
