import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/dades_personals.dart';

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

    // Después de guardar el tipo de usuario, redirigir a la página deseada
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DadesPersonals(userId: userId)),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DadesPersonals(userId: userId)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
