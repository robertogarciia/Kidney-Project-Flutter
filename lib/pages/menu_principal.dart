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
import 'package:kidneyproject/pages/menuDietes.dart';
import 'package:kidneyproject/pages/menu_joc.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/pages/trivial_game.dart';
import 'package:kidneyproject/pages/videos_principal_page.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  Timer? _timer;
  bool _isCheckingMood = false;

  @override
  void initState() {
    super.initState();
    _startMoodCheckTimer();
  }

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
      _timer = Timer.periodic(Duration(minutes: 30), (timer) {
        if (!_isCheckingMood) {
          _isCheckingMood = true;
          print('Navegant a EstatAnim...');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EstatAnim(userId: widget.userId)),
          ).then((_) {
            _isCheckingMood = false;
            print('Regresó de EstatAnim');
          });
        }
      });
    } else {
      print('El tipo de usuario no es Pacient, el temporizador no se activa.');
    }
  } else {
    print('Usuario no encontrado en la base de datos');
  }
}



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
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TopImgs(imagePath: 'lib/images/logoKNP_NT.png'),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: TopImgs(imagePath: 'lib/images/ajustes.png'),
                    ),
                  ),
                ],
              ),

              // Texto "Inicia sessio"
              const Text(
                'Menú Principal',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomImgs(
                    imagePath: 'lib/images/mando.png',
                    onTap: () {
                      navigateToPage(context, MenuJoc(userId: widget.userId));
                    },
                  ),
                  const SizedBox(width: 30),
                  MidleImgs(
                    imagePath: 'lib/images/vids.png',
                    onTap: () {
                      navigateToPage(context, Videos());
                    },
                  )
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MidleImgs(
                    imagePath: 'lib/images/ajuda.png',
                    onTap: () {
                      navigateToPage(context, Ajuda(userId: widget.userId));
                    },
                  ),
                  const SizedBox(width: 30),
                  MidleImgs(
                    imagePath: 'lib/images/inf.png',
                    onTap: () {
                      navigateToPage(context, Information());
                    },
                  )
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MidleImgs(
                    imagePath: 'lib/images/DadesPers.png',
                    width: 155, 
                    height: 155,
                    onTap: () {
                      navigateToPage(context, LesMevesDades(userId: widget.userId));
                    },
                  ),
                  const SizedBox(width: 8),
                  MidleImgs(
                    imagePath: 'lib/images/iconEstatAnim2.png',
                    width: 160, 
                    height: 160,
                    onTap: () {
                      //navigateToPage(context, GraficaEstatAnim(userId: widget.userId));
                    },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MidleImgs(
                    imagePath: 'lib/images/comu.png',
                    height: 155,
                    width: 155,
                    onTap: () {
                      navigateToPage(context, Comunities());
                    },
                  ),
                  const SizedBox(width: 5),
                  MidleImgs(
                    imagePath: 'lib/images/dietas.png',
                      height: 155,
                    width: 155,
                    onTap: () {
                      navigateToPage(context, MenuDietes(userId: widget.userId));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
