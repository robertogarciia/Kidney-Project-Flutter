import 'package:flutter/material.dart';
import 'package:kidneyproject/components/bottom_imgs.dart';
import 'package:kidneyproject/components/midle_imgs.dart';
import 'package:kidneyproject/components/top_imgs.dart';
import 'package:kidneyproject/pages/comunities_principal_page.dart';
import 'package:kidneyproject/pages/dades_personals.dart';
import 'package:kidneyproject/pages/diets_principal_page.dart';
import 'package:kidneyproject/pages/game_principal_page.dart';
import 'package:kidneyproject/pages/help_prinicipal_page.dart';
import 'package:kidneyproject/pages/information_principal_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/pages/trivial_game.dart';
import 'package:kidneyproject/pages/videos_principal_page.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({Key? key, required this.userId}) : super(key: key);

  final String userId;

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
                  SizedBox(width: 200),

                  TopImgs(imagePath: 'lib/images/ajustes.png'),
                ],
              ),

              //text inicia sessio
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
                      navigateToPage(context, TrivialPage(userId: userId));
                    },
                  ),
                  const SizedBox(width: 60),
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
                      navigateToPage(context, Help());
                    },
                  ),
                  const SizedBox(width: 60),
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
                  BottomImgs(
                    imagePath: 'lib/images/dades_pers.png',
                    onTap: () {
                      navigateToPage(context, DadesPersonals(userId: userId));

                    },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomImgs(
                    imagePath: 'lib/images/comu.png',
                    onTap: () {
                      navigateToPage(context, Comunities());
                    },
                  ),
                  SizedBox(width: 20),
                  BottomImgs(
                    imagePath: 'lib/images/dietas.png',
                    onTap: () {
                      navigateToPage(context, Diets());
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
