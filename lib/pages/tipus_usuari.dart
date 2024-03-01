import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/dades_personals.dart';


class TipusUsuari extends StatelessWidget {
  const TipusUsuari({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DadesPersonals()),
    );
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
                'lib/images/logoKNP_NT.png',
                height: 250,
              ),

              const SizedBox( height: 30 ),
    
              BtnGeneral(
                buttonText: "Pacient", 
                onTap: () {
                  iniciS(context);
                },
              ),

              const SizedBox( height: 30 ),

              BtnGeneral(
                buttonText: "Familiar", 
                onTap: () {
                  iniciS(context);
                },
              ),

              const SizedBox( height: 30 ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Si no ho vols indicar',
                        style: TextStyle(color: Colors.grey[700])
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox( height: 30 ),

              BtnGeneral(
                buttonText: "Encara no les vull introduïr", 
                onTap: () {
                  iniciS(context);
                },
              ),      
            ],
          ),
        ),
      ),
    );
  }
}
