import 'package:flutter/material.dart';// Importa la clase CustomSearchDelegate

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Aquí puedes mostrar los resultados de la búsqueda
    return Center(
      child: Text('Resultados para: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Aquí puedes mostrar sugerencias mientras el usuario escribe
    return ListView(
      children: [
        ListTile(
          title: Text('Sugerencia 1'),
          onTap: () {
            // Aquí puedes manejar la selección de la sugerencia
            close(context, 'Sugerencia 1 seleccionada');
          },
        ),
        ListTile(
          title: Text('Sugerencia 2'),
          onTap: () {
            // Aquí puedes manejar la selección de la sugerencia
            close(context, 'Sugerencia 2 seleccionada');
          },
        ),
      ],
    );
  }
}
