import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';
import 'package:kidneyproject/pages/resumDietesPage.dart';

class cestaPage extends StatelessWidget {
  final String userId;
  final String tipusC;
  const cestaPage({Key? key, required this.userId, required this.tipusC}) : super(key: key);

  Future<void> _guardarPuntuacion(
      BuildContext context, int puntuacionTotal) async {
    try {
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dieta Finalitzada Correctament'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
    final cestaProvider = Provider.of<CestaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cistella'),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: cestaProvider.cestaItems.isEmpty
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
                        final item = cestaProvider.cestaItems[index];
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
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cestaProvider.eliminarItem(item['item']);
                              },
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
                                context, cestaProvider.puntuacionTotal,);
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
                          child: Text('Finalizar Dieta'),
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
