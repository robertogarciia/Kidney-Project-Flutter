import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/cestaProvider.dart';
import 'package:provider/provider.dart'; // Importa el paquete Provider

class detallPage extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imageUrl;
  final int puntuacion;

  const detallPage({
    Key? key,
    required this.nombre,
    required this.descripcion,
    required this.imageUrl,
    required this.puntuacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          nombre,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWithPuntuacion(),
            SizedBox(height: 16),
            _buildDescription(),
            SizedBox(height: 16),
            _buildAddToCestaButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithPuntuacion() {
    Color puntuacionColor;

    if (puntuacion == 0) {
      puntuacionColor = Colors.green;
    } else if (puntuacion == 1) {
      puntuacionColor = Colors.orange;
    } else if (puntuacion == 2) {
      puntuacionColor = Colors.red;
    } else {
      puntuacionColor = Colors.greenAccent;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 150,
              width: 150,
            ),
          ),
        ),
        SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: puntuacionColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: puntuacionColor, width: 2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 8),
              Text(
                '$puntuacion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripció:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          SizedBox(height: 8),
          Text(
            descripcion,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

 Widget _buildAddToCestaButton(BuildContext context) {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        final cestaProvider = Provider.of<CestaProvider>(context, listen: false);

        if (cestaProvider.cestaItems.length >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No pots afegir més de 4 elements a la cistella.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          cestaProvider.agregarItem(nombre, puntuacion, imageUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$nombre afegit a la cistella'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.greenAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Afegir a la cistella',
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}

}
