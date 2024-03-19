import 'package:flutter/material.dart';
import 'package:kidneyproject/components/bottom_imgs.dart';
import 'package:kidneyproject/components/btn_iniciSessio.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/components/midle_imgs.dart';
import 'package:kidneyproject/components/top_imgs.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({Key? key}) : super(key: key);

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
      body: const SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TopImgs(imagePath: 'lib/images/logoKNP_NT.png'),
                  SizedBox(width: 200),

                  TopImgs(imagePath: 'lib/images/ajustes.png'),
                ],
              ),

              //text inicia sessio
              Text(
                'Menu Prncipal',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomImgs(
                    imagePath: 'lib/images/dades_pers.png',
                    onTap: () {
                      navigateToPage(context, SignIn());
                    },
                  ),
                  SizedBox(width: 60),
                  MidleImgs(
                    imagePath: 'lib/images/vids.png',
                    onTap: () {
                      navigateToPage(context, SignIn());
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
                      goToJoc(context);
                    },
                  ),
                  SizedBox(width: 60),
                  MidleImgs(
                    imagePath: 'lib/images/inf.png',
                    onTap: () {
                      goToJoc(context);
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
                      goToJoc(context);
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
                      goToJoc(context);
                    },
                  ),
                  SizedBox(width: 20),
                  BottomImgs(
                    imagePath: 'lib/images/dietas.png',
                    onTap: () {
                      goToJoc(context);
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
