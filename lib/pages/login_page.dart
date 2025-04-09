import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para SystemNavigator
import 'package:kidneyproject/components/button.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoose()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Aquí mostramos un cuadro de diálogo para confirmar si el usuario quiere salir
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Estàs segur que vols tancar l\'aplicació?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No salir
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Salir
                },
                child: Text('Sortir'),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          // Si el usuario quiere salir, cerramos la aplicación de forma más confiable
          SystemNavigator.pop(); // Cerrar la aplicación
        }

        return false; // No bloquear la acción por sí sola, ya que manejamos el cierre con SystemNavigator.pop()
      },
      child: Scaffold(
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
                  'Inicia sessió',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'lib/images/logoKNP_WT.png',
                  height: 300,
                ),
                const SizedBox(height: 30),
                //Introduccio Correu
                BtnIniciSessio(
                  onTap: () {
                    iniciS(context);
                  },
                ),
                const SizedBox(height: 15),
                Text(
                  'Si no tens un compte, registrat!',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                const SizedBox(height: 15),
                BtnRegistrar(
                  onTap: () {
                    register(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
