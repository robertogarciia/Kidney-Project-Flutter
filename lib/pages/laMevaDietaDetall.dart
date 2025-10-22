import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class laMevaDietaDetall extends StatefulWidget {
  final String userId; // ID de l'usuari
  final String nombre;
  final int puntuacionTotal;
  final List alimentos;
  final DateTime fechaCreacion;
  final String dietaId;
  final Future<void> Function(String dietaId) onDelete;
  final bool esFavorito;

  const laMevaDietaDetall({
    Key? key,
    required this.userId,
    required this.nombre,
    required this.puntuacionTotal,
    required this.alimentos,
    required this.fechaCreacion,
    required this.dietaId,
    required this.onDelete,
    required this.esFavorito,
  }) : super(key: key);

  @override
  _laMevaDietaDetallState createState() => _laMevaDietaDetallState();
}

class _laMevaDietaDetallState extends State<laMevaDietaDetall> {
  late bool esFavorito;

  @override
  void initState() {
    super.initState();
    esFavorito = widget.esFavorito;
    print('id de la dieta: ${widget.dietaId}');

    // Cargar el estado 'favorito' desde Firestore y mostrarlo en la consola
    _loadEstadoFavorito();
  }

  Future<void> _loadEstadoFavorito() async {
    final dietaRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('resumDietes')
        .doc(widget.dietaId);

    try {
      DocumentSnapshot snapshot = await dietaRef.get();

      if (snapshot.exists) {
        print('Documento encontrado: ${snapshot.data()}');
        bool estadoFavorito = snapshot['favorito'] ?? false;
        print('Estado de favorito al cargar: $estadoFavorito');

        // ACTUALIZAMOS el estado local
        setState(() {
          esFavorito = estadoFavorito;
        });
      } else {
        print('No se encontró el documento, estado de favorito por defecto: false');
      }
    } catch (e) {
      print('Error al cargar el estado de favorito: $e');
    }
  }


  String _evaluarDieta() {
    if (widget.puntuacionTotal == 0) {
      return 'Enhorabona! La dieta creada és excel·lent.';
    } else if (widget.puntuacionTotal == 1) {
      return 'Aquesta dieta és millorable. Hi han millors aliments a triar.';
    } else {
      return 'Aquesta dieta no és recomanable. Hi han aliments que no són bons per a tu.';
    }
  }

  Future<void> _toggleFavorito() async {
    bool nuevoEstado = !esFavorito;
    setState(() {
      esFavorito = nuevoEstado;
    });

    final dietaRef = FirebaseFirestore.instance
        .collection('Usuarios')  // Accedemos a la colección Usuarios
        .doc(widget.userId)      // Usamos el userId para acceder al documento de usuario
        .collection('resumDietes') // Luego accedemos a la subcolección resumDietes
        .doc(widget.dietaId);   // Y finalmente el documento dentro de resumDietes

    try {
      DocumentSnapshot snapshot = await dietaRef.get();

      if (snapshot.exists) {
        // Si el documento existe, lo actualizamos
        await dietaRef.update({'favorito': nuevoEstado});
        print('Estado de favorito actualizado a $nuevoEstado');
      } else {
        // Si el documento no existe, lo creamos
        await dietaRef.set({
          'favorito': nuevoEstado,
          'nombre': widget.nombre,
          'puntuacionTotal': widget.puntuacionTotal,
          'fechaCreacion': widget.fechaCreacion,
          'alimentos': widget.alimentos,
        });
        print('Documento creado con estado de favorito $nuevoEstado');
      }
    } catch (e) {
      print('Error al actualizar o crear favorito: $e');
      setState(() {
        esFavorito = !nuevoEstado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detall de la Dieta'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        esFavorito ? Icons.star : Icons.star_border,
                        color: esFavorito ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        _toggleFavorito();
                      },
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Eliminar dieta'),
                                content: const Text('Estàs segur de que vols eliminar aquesta dieta?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Eliminar'),
                                    onPressed: () async {
                                      await widget.onDelete(widget.dietaId);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Puntuació Total: ${widget.puntuacionTotal}',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Creada el: ${DateFormat('dd/MM/yyyy').format(widget.fechaCreacion)}',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: widget.puntuacionTotal == 0
                      ? Colors.green.withOpacity(0.2)
                      : (widget.puntuacionTotal == 1
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.puntuacionTotal == 0
                        ? Colors.green
                        : (widget.puntuacionTotal == 1 ? Colors.orange : Colors.red),
                    width: 2,
                  ),
                ),
                child: Text(
                  _evaluarDieta(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.puntuacionTotal == 0
                        ? Colors.green
                        : (widget.puntuacionTotal == 1 ? Colors.orange : Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aliments de la Dieta:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: widget.alimentos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final alimento = widget.alimentos[index];
                final imageUrl = alimento['imageUrl'] ?? '';
                final nombreProducto = alimento['item'] ?? 'Sense nom';
                final puntuacion = alimento['puntuacion'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    color: _getCardColor(puntuacion),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      leading: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        nombreProducto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Puntuació: $puntuacion',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tileColor: Colors.transparent,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int puntuacion) {
    switch (puntuacion) {
      case 1:
        return Colors.orangeAccent.shade200;
      case 2:
        return Colors.redAccent.shade200;
      default:
        return Colors.greenAccent.shade200;
    }
  }
}
