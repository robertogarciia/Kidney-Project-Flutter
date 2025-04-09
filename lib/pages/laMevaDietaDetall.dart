import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class laMevaDietaDetall extends StatelessWidget {
  final String nombre;
  final int puntuacionTotal;
  final List alimentos;
  final DateTime fechaCreacion;
  final String dietaId;
  final Future<void> Function(String dietaId) onDelete;

  const laMevaDietaDetall({
    Key? key,
    required this.nombre,
    required this.puntuacionTotal,
    required this.alimentos,
    required this.fechaCreacion,
    required this.dietaId,
    required this.onDelete,
  }) : super(key: key);

  String _evaluarDieta() {
    if (puntuacionTotal == 0) {
      return 'Enhorabona! La dieta creada és excel·lent.';
    } else if (puntuacionTotal == 1) {
      return 'Aquesta dieta és millorable. Hi han millors aliments a triar.';
    } else {
      return 'Aquesta dieta no és recomanable. Hi han aliments que no són bons per a tu.';
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
            // Título y botó de eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), // Fondo suave rojo
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
                                  await onDelete(dietaId);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.red, // Color del icono
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Puntuació total
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Puntuació Total: $puntuacionTotal',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // data de creació
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Creada el: ${DateFormat('dd/MM/yyyy').format(fechaCreacion)}',
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
                  color: puntuacionTotal == 0
                      ? Colors.green.withOpacity(0.2)
                      : (puntuacionTotal == 1 ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: puntuacionTotal == 0
                        ? Colors.green
                        : (puntuacionTotal == 1 ? Colors.orange : Colors.red),
                    width: 2,
                  ),
                ),
                child: Text(
                  _evaluarDieta(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: puntuacionTotal == 0
                        ? Colors.green
                        : (puntuacionTotal == 1 ? Colors.orange : Colors.red),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Aliments de la Dieta:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Llista de aliments
            ListView.builder(
              itemCount: alimentos.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final alimento = alimentos[index];
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
// depen de la puntuació, retorna un color diferent
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
