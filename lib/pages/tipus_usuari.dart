import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/dades_familiars2.dart';
import 'package:kidneyproject/pages/dades_personals.dart';
import 'package:kidneyproject/pages/menu_principal.dart'; // Importa la página principal
// Importa la página dades_familiars.dart
import 'package:kidneyproject/pages/dades_familiars.dart';

class TipusUsuari extends StatelessWidget {
  final String userId;

  const TipusUsuari({Key? key, required this.userId}) : super(key: key);

  Future<void> actualizarTipoUsuario(BuildContext context, String tipoUsuario) async {
    // Guardar el tipo de usuario en la colección 'tipusDeUsuario' dentro del documento del usuario
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .set({'tipus': tipoUsuario});

    // Redirigir a la página correspondiente según el tipo de usuario seleccionado
    if (tipoUsuario == 'Pacient') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DadesPersonals(userId: userId)),
      );
    } else if (tipoUsuario == 'Familiar') {
     
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DadesFamiliars(userId: userId)), 
  );


    } else {
     Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPrincipal(userId: userId)),
      );
    }
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
              const Text(
                "Tipo de Usuario",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BtnGeneral(
                buttonText: "Pacient",
                onTap: () {
                  actualizarTipoUsuario(context, 'Pacient');
                },
              ),
              const SizedBox(height: 20),
              BtnGeneral(
                buttonText: "Familiar",
                onTap: () {
                  actualizarTipoUsuario(context, 'Familiar');
                },
              ),
              const SizedBox(height: 20),
              BtnGeneral(
                buttonText: "No quiero ingresarlos todavía",
                onTap: () {
                  actualizarTipoUsuario(context, 'No quiero ingresarlos todavía');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
