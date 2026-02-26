import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/crearDietes.dart';
import 'package:kidneyproject/pages/lesMevesDietes.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
import 'package:provider/provider.dart';
import 'cestaProvider.dart';

class MenuDietes extends StatefulWidget {
  final String userId;
  final String pacienteId; // Id del paciente que ve el familiar (opcional)

  const MenuDietes({Key? key, required this.userId, this.pacienteId = ''})
      : super(key: key);

  @override
  _MenuDietesState createState() => _MenuDietesState();
}

class _MenuDietesState extends State<MenuDietes> {
  String _tipusC = '';
  String _tipoUsuario = '';
  bool _datosCargados = false;
  bool _mostrarLoading = false;

  @override
  void initState() {
    super.initState();
    _startLoadingTimer();
    _loadData();
  }

  void _startLoadingTimer() {
    Timer(const Duration(milliseconds: 500), () {
      if (!_datosCargados) {
        setState(() {
          _mostrarLoading = true;
        });
      }
    });
  }

  Future<void> _loadData() async {
    await _getTipoUsuario();
    await _getTipusC();
    setState(() {
      _datosCargados = true;
      _mostrarLoading = false;
    });
  }

  Future<void> _getTipusC() async {
    try {
      final String idCorrecto =
          (_tipoUsuario == 'Familiar' && widget.pacienteId.isNotEmpty)
              ? widget.pacienteId
              : widget.userId;

      print('Tipo usuario: $_tipoUsuario');
      print('UserId: ${widget.userId}');
      print('PacienteId: ${widget.pacienteId}');
      print('ID usado para cargar dadesMediques: $idCorrecto');

      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(idCorrecto)
          .collection('dadesMediques')
          .doc('datos')
          .get();

      print('Documento existe: ${docSnapshot.exists}');
      print('Datos documento: ${docSnapshot.data()}');

      if (docSnapshot.exists) {
        _tipusC = docSnapshot['tipusC'] ?? '';
        print('TipusC obtenido: $_tipusC');
      } else {
        _tipusC = 'Desconocido';
        print('No existe dadesMediques/datos para ese usuario');
      }
    } catch (e) {
      print('Error al obtener dades: $e');
    }
  }

  Future<void> _getTipoUsuario() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .get();

      if (userDoc.exists) _tipoUsuario = userDoc['tipo'] ?? '';
    } catch (e) {
      print('Error al obtener el tipo de usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cestaProvider = Provider.of<CestaProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Dietes'),
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (cestaProvider.cestaItems.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Alerta'),
                  content: const Text(
                      'Tens elements en la cistella. Segur que et vols dirigir al menú principal?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MenuPrincipal(userId: widget.userId)),
                        );
                      },
                      child: const Text('Sí, vull continuar'),
                    ),
                  ],
                ),
              );
            } else {
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

                    // Crear dietes
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => crearDietes(
                                userId: widget.userId, tipusC: _tipusC),
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.add, size: 30, color: Colors.white),
                      label: const Text('Crear Dietes',
                          style: TextStyle(fontSize: 25)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: const Size(300, 70),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Ver dietes del paciente (si es familiar)
                    ElevatedButton(
                      onPressed: () {
                        final idParaVer = _tipoUsuario == 'Familiar' &&
                                widget.pacienteId.isNotEmpty
                            ? widget.pacienteId
                            : widget.userId;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => lesMevesDietes(
                                userId: idParaVer,
                                pacienteId: widget.pacienteId,
                                mostrarSoloPropias: false),
                          ),
                        );
                      },
                      child: Text(
                        _tipoUsuario == 'Familiar'
                            ? 'Veure Dietes Pacient'
                            : 'Veure Dietes',
                        style: const TextStyle(fontSize: 25),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: const Size(300, 70),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ver dietes propias del familiar
                    // Ver dietes propias del familiar
                    if (_tipoUsuario == 'Familiar')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => lesMevesDietes(
                                  userId: widget.userId,
                                  pacienteId: widget.pacienteId,
                                  mostrarSoloPropias: true),
                            ),
                          );
                        },
                        child: const Text('Veure les meves dietes creades',
                            style: TextStyle(fontSize: 25)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: const Size(300, 70),
                        ),
                      ),
                  ],
                )
              : _mostrarLoading
                  ? const CircularProgressIndicator()
                  : Container(),
        ),
      ),
    );
  }
}
