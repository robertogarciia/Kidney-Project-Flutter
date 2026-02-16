import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kidneyproject/pages/cestaPage.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';
import 'package:kidneyproject/pages/pageCarns.dart';
import 'package:kidneyproject/pages/pageCondiments.dart';
import 'package:kidneyproject/pages/pageDolcos.dart';
import 'package:kidneyproject/pages/pageEmbotits.dart';
import 'package:kidneyproject/pages/pageFruita.dart';
import 'package:kidneyproject/pages/pageGreixos.dart';
import 'package:kidneyproject/pages/pageLactics.dart';
import 'package:kidneyproject/pages/pageLlegums.dart';
import 'package:kidneyproject/pages/pageOu.dart';
import 'package:kidneyproject/pages/pagePeix.dart';
import 'package:kidneyproject/pages/pageTubercles.dart';
import 'package:kidneyproject/pages/pageVerdures.dart';
import 'package:provider/provider.dart';
import 'package:kidneyproject/pages/menuDietes.dart';

class crearDietes extends StatefulWidget {
  final String userId;
  final String tipusC;

  const crearDietes({Key? key, required this.userId, required this.tipusC})
      : super(key: key);

  @override
  _crearDietesState createState() => _crearDietesState();
}

class _crearDietesState extends State<crearDietes> {
  @override
  void initState() {
    super.initState();
    print("TipusC: ${widget.tipusC}");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CestaProvider(), // Proveedor per a gestionar la cistella
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menú Dietes'),
          backgroundColor: Colors.greenAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuDietes(
                    userId: widget.userId, // Pasa el userId a la nova pàgina
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart), // Icono de cesta
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => cestaPage(
                      userId: widget.userId, // Pasa el userId a la nova pàgina
                      tipusC: widget.tipusC, // Pasa el tipusC a la nova pàgina
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            // A segura que els elements estiguin centrats
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Evitar que se estiri la columna
                children: [
                  _buildButton('Peix', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pagePeix(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Carns', () {
                    // Acció al presionar "Carns"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => pageCarns(
                            userId: widget.userId, tipusC: widget.tipusC),
                      ),
                    );
                  }),
                  _buildButton('Ous', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageOu(userId: widget.userId, tipusC: widget.tipusC),
                    ),
                  );
                  }),
                  _buildButton('Embotits', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageEmbotits(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Làctics', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageLactics(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Llegums', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageLlegums(userId: widget.userId,tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Verdures', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageVerdures(userId: widget.userId,tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Tubèrcles', () { 
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageTubercles(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );

                  }),
                  _buildButton('Fruites', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageFruita(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Grases', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageGreixos(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Dolços', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageDolcos(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                  _buildButton('Condiments i salses', () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageCondiments(userId: widget.userId, tipusC: widget.tipusC,),
                    ),
                  );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            minimumSize: Size(300, 50),
          ),
        ),
        const SizedBox(height: 20), // Espacio entre los botones
      ],
    );
  }
}
