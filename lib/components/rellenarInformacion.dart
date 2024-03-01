import 'package:flutter/material.dart';

class RellenarEscribiendo extends StatefulWidget {
  @override
  _RellenarEscribiendoState createState() => _RellenarEscribiendoState();
}

class _RellenarEscribiendoState extends State<RellenarEscribiendo> {
  String texto = '';

  Widget _buildDadesPersonalsComponent() {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:const SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              // Texto "Dades Personals"
              Text(
                "Dades Personals",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rellenar Escribiendo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    texto = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Escribe algo',
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Texto escrito: $texto',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 20.0),
              // Llamando al método para añadir el componente
              _buildDadesPersonalsComponent(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RellenarEscribiendo(),
  ));
}
