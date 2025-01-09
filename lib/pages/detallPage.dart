import 'package:flutter/material.dart';

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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  // Widget que muestra la imagen más grande y la puntuación en recuadros separados
  Widget _buildImageWithPuntuacion() {
    Color puntuacionColor;

    // Cambiar el color de fondo según la puntuación
    if (puntuacion == 0) {
      puntuacionColor = Colors.red; // Fondo rojo si la puntuación es 0
    } else if (puntuacion == 1) {
      puntuacionColor = Colors.orange; // Fondo naranja si la puntuación es 1
    } else if (puntuacion == 2) {
      puntuacionColor = Colors.green; // Fondo verde si la puntuación es 2
    } else {
      puntuacionColor = Colors.greenAccent; // Color predeterminado
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen más grande dentro de un recuadro verde
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
              height: 150, // Tamaño más grande para la imagen
              width: 150,
            ),
          ),
        ),
        SizedBox(width: 16), // Espacio entre la imagen y la puntuación

        // Puntuación con fondo dependiendo del valor
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: puntuacionColor, // Fondo dependiendo de la puntuación
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: puntuacionColor, width: 2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.white, // Estrella blanca para resaltar sobre el fondo
                size: 30,
              ),
              SizedBox(width: 8),
              Text(
                '$puntuacion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto blanco
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para la descripción
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
            'Descripción:',
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

  // Widget para el botón de regresar
  Widget _buildBackButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.greenAccent,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Afegir a la cistella',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
