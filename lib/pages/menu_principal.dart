import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/bottom_imgs.dart';
import 'package:kidneyproject/components/midle_imgs.dart';
import 'package:kidneyproject/components/top_imgs.dart';
import 'package:kidneyproject/pages/ajuda.dart';
import 'package:kidneyproject/pages/comunities_principal_page.dart';
import 'package:kidneyproject/pages/dades_personals.dart';
import 'package:kidneyproject/pages/diets_principal_page.dart';
import 'package:kidneyproject/pages/estatAnim.dart';
import 'package:kidneyproject/pages/game_principal_page.dart';
import 'package:kidneyproject/pages/graficaEstatAnim.dart';
import 'package:kidneyproject/pages/help_prinicipal_page.dart';
import 'package:kidneyproject/pages/information_principal_page.dart';
import 'package:kidneyproject/pages/lesMevesDades.dart';
import 'package:kidneyproject/pages/logrosPage.dart';
import 'package:kidneyproject/pages/menuDietes.dart';
import 'package:kidneyproject/pages/menu_joc.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/trivial_game.dart';
import 'package:kidneyproject/pages/videos_principal_page.dart';
import 'package:kidneyproject/pages/graficaEstatAnim.dart';
import 'package:kidneyproject/pages/noticiesPage.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  Timer? _timer;
  bool _isCheckingMood =
      false; // Bandera para evitar múltiples navegaciones simultáneas

  @override
  void initState() {
    super.initState();
    // _startMoodCheckTimer();
  }

/*
  void _startMoodCheckTimer() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    if (userSnapshot.exists) {
      String tipoUsuario = userSnapshot['tipo'];

      if (tipoUsuario == 'Pacient') {
        print('Temporizador iniciat');
        _timer = Timer.periodic(Duration(minutes: 10), (timer) {
          if (!_isCheckingMood) {
            _isCheckingMood = true;
            print('Navegant a EstatAnim...');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EstatAnim(userId: widget.userId)),
            ).then((_) {
              _isCheckingMood = false;
              print('Regresó de EstatAnim');
            });
          }
        });
      } else {
        print(
            'El tipo de usuario no es Pacient, el temporizador no se activa.');
      }
    } else {
      print('Usuario no encontrado en la base de datos');
    }
  }
*/
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
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
        bool cerrarSesion = await mostrarDialogoCerrarSesion(context);
        return cerrarSesion; // Devuelve `true` para salir, `false` para quedarse
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5),
                Row(
                  children: [
                    const TopImgs(imagePath: 'assets/images/logoKNP_NT.png'),
                    Spacer(), // empuja el botón a la derecha
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0), // margen desde la derecha
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LogrosPage(userId: widget.userId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700], // fondo amarillo
                          elevation: 6, // relieve
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // esquinas redondeadas
                          ),
                          padding: EdgeInsets.all(12), // tamaño del botón
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors
                              .white, // estrella blanca sobre fondo amarillo
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Menú Principal',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BottomImgs(
                      imagePath: 'assets/images/mando.png',
                      onTap: () {
                        navigateToPage(context, MenuJoc(userId: widget.userId));
                      },
                    ),
                    const SizedBox(width: 30),
                    MidleImgs(
                      imagePath: 'assets/images/vids.png',
                      onTap: () {
                        navigateToPage(context, Videos(userId: widget.userId));
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/ajuda.png',
                      onTap: () {
                        navigateToPage(context, Ajuda(userId: widget.userId));
                      },
                    ),
                    const SizedBox(width: 30),
                    MidleImgs(
                      imagePath: 'assets/images/inf.png',
                      onTap: () {
                        navigateToPage(
                            context, noticiesPage(userId: widget.userId));
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/DadesPers.png',
                      width: 155,
                      height: 155,
                      onTap: () {
                        navigateToPage(
                            context, LesMevesDades(userId: widget.userId));
                      },
                    ),
                    const SizedBox(width: 8),
                    MidleImgs(
                      imagePath: 'assets/images/iconEstatAnim2.png',
                      width: 160,
                      height: 160,
                      onTap: () {
                        navigateToPage(
                            context, graficaEstatAnim(userId: widget.userId));
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/comu.png',
                      height: 155,
                      width: 155,
                      onTap: () {
                        navigateToPage(
                            context, Comunities(userId: widget.userId));
                      },
                    ),
                    const SizedBox(width: 5),
                    MidleImgs(
                      imagePath: 'assets/images/imatgeDietes.png',
                      height: 155,
                      width: 150,
                      onTap: () {
                        navigateToPage(
                            context, MenuDietes(userId: widget.userId));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> mostrarDialogoCerrarSesion(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Tancar sessió"),
            content: const Text("Estàs segur de que vols tancar la sessió?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Cierra el diálogo antes de navegar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignIn()), // Redirige al login
                  );
                },
                child: const Text("Tancar sessió"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
