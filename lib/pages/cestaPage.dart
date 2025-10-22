import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/crearDietes.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';
import 'package:kidneyproject/pages/resumDietesPage.dart';

// Aquesta pàgina mostra els elements afegits a la cistella i permet finalitzar la dieta.
class cestaPage extends StatelessWidget {
  final String userId; // ID de l'usuari
  final String tipusC; // Tipus de dieta

  const cestaPage({Key? key, required this.userId, required this.tipusC}) : super(key: key);

  // Funció per guardar la puntuació de la dieta finalitzada.
  Future<void> _guardarPuntuacion(BuildContext context, int puntuacionTotal) async {
    try {
      // Mostra un missatge de confirmació a l'usuari.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dieta Finalitzada Correctament'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostra un missatge d'error si la dieta no es pot finalitzar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al finalitzar la Dieta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cestaProvider = Provider.of<CestaProvider>(context); // Obtenim el proveïdor de la cistella

    return Scaffold(
        appBar: AppBar(
          title: const Text('Cistella'),
          backgroundColor: Colors.greenAccent,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => crearDietes(
                    userId: userId,
                    tipusC: tipusC,
                  ),
                ),
              );
            },
          ),
        ),

      body: cestaProvider.cestaItems.isEmpty // Si la cistella està buida
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'La cistella està buida.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cestaProvider.cestaItems.length,
                itemBuilder: (context, index) {
                  final item = cestaProvider.cestaItems[index]; // Obtenim cada element de la cistella
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      title: Text(item['item'],
                          style: TextStyle(fontSize: 18)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final itemActual = item['item'];

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Editar aliment'),
                                  content: Text('Estàs segur que vols editar aquest aliment?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel·lar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        cestaProvider.eliminarItem(itemActual);
                                        Navigator.pop(context); // Tanca el diàleg

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => crearDietes(
                                              userId: userId,
                                              tipusC: tipusC,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Sí, editar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Eliminar aliment'),
                                  content: Text('Estàs segur que vols eliminar aquest aliment de la cistella?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel·lar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        cestaProvider.eliminarItem(item['item']);
                                        Navigator.pop(context); // Tanca el diàleg
                                      },
                                      child: Text('Sí, eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),


                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mostra la puntuació total
                  Text(
                    'Puntuació Total: ${cestaProvider.puntuacionTotal}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _guardarPuntuacion(
                          context, cestaProvider.puntuacionTotal);
                      // Navegar a la pàgina de resum de la dieta
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => resumDietesPage(
                              userId: userId,
                              tipusC: tipusC,
                              puntuacionTotal: cestaProvider.puntuacionTotal,
                              alimentos: cestaProvider.cestaItems,
                            )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Finalitzar Dieta'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
