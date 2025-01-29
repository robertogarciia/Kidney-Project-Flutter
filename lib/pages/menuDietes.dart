import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/crearDietes.dart';
import 'package:kidneyproject/pages/lesMevesDietes.dart';
import 'package:kidneyproject/pages/menu_principal.dart'; 

class MenuDietes extends StatefulWidget {
  final String userId;

  const MenuDietes({Key? key, required this.userId}) : super(key: key);

  @override
  _MenuDietesState createState() => _MenuDietesState();
}

class _MenuDietesState extends State<MenuDietes> {
  String _tipusC = '';

  @override
  void initState() {
    super.initState();
    _getTipusC();
  }

  Future<void> _getTipusC() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesMediques')
          .doc('datos')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _tipusC = docSnapshot['tipusC'] ?? '';
        });
        print("TipusC recuperado: $_tipusC");
      } else {
        setState(() {
          _tipusC = 'Desconocido';
        });
        print("Documento no encontrado. TipusC es 'Desconocido'.");
      }
    } catch (e) {
      print('Error al obtener dades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Dietes'),
        backgroundColor: Colors.greenAccent,
        leading: IconButton(  
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPrincipal(userId: widget.userId),  
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () {
                  // Acción al presionar "Crear Dietes"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => crearDietes(userId: widget.userId, tipusC: _tipusC),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
                label: const Text(
                  'Crear Dietes',
                  style: TextStyle(fontSize: 25),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: Size(300, 70),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => lesMevesDietes(userId: widget.userId, tipusC: _tipusC),
                    ),
                  );
                },
                child: const Text(
                  'Veure Dietes',
                  style: TextStyle(fontSize: 25),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: Size(300, 70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
