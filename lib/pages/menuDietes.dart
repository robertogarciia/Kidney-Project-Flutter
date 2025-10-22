import 'dart:async'; // Import necesario para Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/crearDietes.dart';
import 'package:kidneyproject/pages/lesMevesDietes.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:provider/provider.dart';
import 'cestaProvider.dart';

class MenuDietes extends StatefulWidget {
  final String userId;

  const MenuDietes({Key? key, required this.userId}) : super(key: key);

  @override
  _MenuDietesState createState() => _MenuDietesState();
}

class _MenuDietesState extends State<MenuDietes> {
  String _tipusC = '';
  String _tipoUsuario = '';
  bool _datosCargados = false;
  bool _mostrarLoading = false; // Nuevo flag para mostrar loading

  @override
  void initState() {
    super.initState();
    _startLoadingTimer();
    _loadData();
  }
// funció per començar el temporitzador de càrrega
  void _startLoadingTimer() {
    Timer(Duration(milliseconds: 500), () {
      if (!_datosCargados) {
        setState(() {
          _mostrarLoading = true;
        });
      }
    });
  }
// funció per carregar les dades
  Future<void> _loadData() async {
    await _getTipusC();
    await _getTipoUsuario();
    setState(() {
      _datosCargados = true;
      _mostrarLoading = false;
    });
  }
// Funció per obtenir el tipus C
  Future<void> _getTipusC() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesMediques')
          .doc('datos')
          .get();

      if (docSnapshot.exists) {
        _tipusC = docSnapshot['tipusC'] ?? '';
      } else {
        _tipusC = 'Desconocido';
      }
    } catch (e) {
      print('Error al obtener dades: $e');
    }
  }
// funció per obtenir el tipus de l'usuari
  Future<void> _getTipoUsuario() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .get();

      if (userDoc.exists) {
        _tipoUsuario = userDoc['tipo'] ?? '';
      }
    } catch (e) {
      print('Error al obtener el tipo de usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accede al CestaProvider
    final cestaProvider = Provider.of<CestaProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Dietes'),
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Comprobamos si hay elementos en la cesta
            if (cestaProvider.cestaItems.isNotEmpty) { // Usa cestaProvider aquí
              // Si la cesta tiene elementos, mostramos un dialog de confirmación
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Alerta'),
                  content: Text('Tens elements en la cistella. Segur que et vols dirigir al menú principal?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar el dialog
                      },
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar el dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPrincipal(userId: widget.userId),
                          ),
                        );
                      },
                      child: Text('Sí, vull continuar'),
                    ),
                  ],
                ),
              );
            } else {
              // Si no hay elementos en la cesta, simplemente navegar
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPrincipal(userId: widget.userId),
                ),
              );
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _datosCargados
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              if (_tipoUsuario != 'Familiar')
                ElevatedButton.icon(
                  onPressed: () {
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
          )
              : _mostrarLoading
              ? CircularProgressIndicator() // Solo se muestra si tarda más de 500ms
              : Container(), // No muestra nada si aún no pasó el tiempo
        ),
      ),
    );
  }


}
