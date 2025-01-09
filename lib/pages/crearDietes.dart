import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/pageCarns.dart';

class crearDietes extends StatefulWidget {
  final String userId;
  final String tipusC;

  const crearDietes({Key? key, required this.userId, required this.tipusC}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Dietes'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView( 
        child: Center( 
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                _buildButton('Peix', () {
                  // Acción al presionar "Peix"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Carns', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pageCarns(userId: widget.userId, tipusC: widget.tipusC),
                    ),
                  );
                }),
                _buildButton('Ous', () {
                  // Acción al presionar "Ous"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Embotits', () {
                  // Acción al presionar "Embotits"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Làctics', () {
                  // Acción al presionar "Làctics"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Llegums', () {
                  // Acción al presionar "Llegums"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Verdures', () {
                  // Acción al presionar "Verdures"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Fruites', () {
                  // Acción al presionar "Fruites"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Grases', () {
                  // Acción al presionar "Grases"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Dolços', () {
                  // Acción al presionar "Dolços"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
                _buildButton('Condiments i salses', () {
                  // Acción al presionar "Condiments i salses"
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearDietesPage(userId: widget.userId),
                    ),
                  );*/
                }),
              ],
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
        const SizedBox(height: 20), 
      ],
    );
  }
}
