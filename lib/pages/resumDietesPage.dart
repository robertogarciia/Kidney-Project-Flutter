import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/menuDietes.dart';
import 'package:provider/provider.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';

class resumDietesPage extends StatefulWidget {
  final String userId;
  final String tipusC;
  final int puntuacionTotal;
  final List<Map<String, dynamic>> alimentos;

  const resumDietesPage({
    Key? key,
    required this.userId,
    required this.tipusC,
    required this.puntuacionTotal,
    required this.alimentos,
  }) : super(key: key);

  @override
  _resumDietesPageState createState() => _resumDietesPageState();
}
// funció per a la puntuació de la dieta
class _resumDietesPageState extends State<resumDietesPage> {
  final TextEditingController _nombreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool mostrarImagen = false;
  String? rutaImagen;

  bool isMounted = true;

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }
// funció per avaluar la dieta
  String _evaluarDieta() {
    if (widget.puntuacionTotal == 0) {
      return 'Enhorabona! La dieta creada és excel·lent.';
    } else if (widget.puntuacionTotal == 1) {
      return 'Aquesta dieta és millorable. Hi han millors aliments a triar.';
    } else {
      return 'Aquesta dieta no és recomanable. Hi han aliments que no són bons per a tu.';
    }
  }
// funció per guardar el resum de la dieta

  Future<void> _guardarResumen() async {
    final String nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Afegeix un nom per a la dieta.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Timestamp fechaCreacion = Timestamp.now();

    try {
      // Guardar dieta
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('resumDietes')
          .add({
        'nombre': nombre,
        'fechaCreacion': fechaCreacion,
        'favorito': false,
        'puntuacionTotal': widget.puntuacionTotal,
        'alimentos': widget.alimentos,
      });

      // Coins segons puntuació
      int coinsToAdd = 0;
      if (widget.puntuacionTotal == 0) {
        coinsToAdd = 50;
      } else if (widget.puntuacionTotal == 1) {
        coinsToAdd = 20;
      } else if (widget.puntuacionTotal == 2) {
        coinsToAdd = -10;
      }

      final datosRef = FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final datosSnapshot = await transaction.get(datosRef);

        if (!datosSnapshot.exists) {
          transaction.set(datosRef, {'coins': coinsToAdd});
        } else {
          int coinsActuales = datosSnapshot.get('coins') ?? 0;
          transaction.update(datosRef, {'coins': coinsActuales + coinsToAdd});
        }
      });

      // Mostrar imagen después de guardar la dieta
      setState(() {
        rutaImagen = puntuacionImagePath(widget.puntuacionTotal);
        mostrarImagen = true;
      });

      // Esperar 1 segundo antes de ocultar la imagen
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        setState(() {
          mostrarImagen = false;
        });
      }

      // Mostrar el mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dieta guardada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );

        final cestaProvider = Provider.of<CestaProvider>(context, listen: false);
        cestaProvider.vaciarCesta();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDietes(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la dieta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String puntuacionImagePath(int puntuacionTotal) {
    if (puntuacionTotal == 0) {
      return 'lib/images/+50Puntos.png';
    } else if (puntuacionTotal == 1) {
      return 'lib/images/+10Puntos.png';
    } else {
      return 'lib/images/-10puntos.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    final String mensajeEvaluacion = _evaluarDieta();

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de la Dieta'),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Introdueix un nom per a la dieta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nom de la dieta',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre no puede estar vacío';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  for (var alimento in widget.alimentos)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: alimento['puntuacion'] == 0
                            ? Colors.green.withOpacity(0.8)
                            : (alimento['puntuacion'] == 1
                            ? Colors.orange.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                alimento['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Puntuación: ${alimento['puntuacion']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntuació Total: ${widget.puntuacionTotal}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mensajeEvaluacion,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.puntuacionTotal == 0
                                ? Colors.green
                                : (widget.puntuacionTotal == 1
                                ? Colors.orange
                                : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarResumen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Guardar Dieta'),
                  ),
                ],
              ),
            ),
          ),

          // Imagen superpuesta que aparece durante 1 segundo
          if (mostrarImagen && rutaImagen != null)
            AnimatedOpacity(
              opacity: mostrarImagen ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Image.asset(
                      rutaImagen!,
                      width: 250,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}
