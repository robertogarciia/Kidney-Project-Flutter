import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/components/custom_search_delegate.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  // Lista de categorías
  final List<String> _categories = ['Todos', 'Hemodiálisis', 'Diálisis Peritoneal', 'Nutrición', 'Consejos'];
  String _selectedCategory = 'Todos';

  // Datos de videos con categorías
  final List<Map<String, dynamic>> _videoData = [
    {'url': 'https://www.youtube.com/watch?v=3hQdl9lRYL0&t=56s', 'title': '¿Qué es la hemodiálisis?', 'category': 'Hemodiálisis'},
    {'url': 'https://www.youtube.com/watch?v=xUyEkXXcig8', 'title': 'Diálisis', 'category': 'Diálisis Peritoneal'},
    {'url': 'https://www.youtube.com/watch?v=OJJ_Xrlq7QI', 'title': '¿Cuántos litros de líquido se eliminan durante la hemodiálisis?', 'category': 'Hemodiálisis'},
    {'url': 'https://www.youtube.com/watch?v=KIfjL4O6uQk', 'title': 'Consejos sobre cuidados para pacientes en hemodiálisis, IGSS TV 207', 'category': 'Diálisis Peritoneal'},
    {'url': 'https://www.youtube.com/watch?v=Y09v5emN0c0', 'title': '🚩Alimentos PROHIBIDOS para la INSUFICIENCIA RENAL Nutricion en pacientes con insuficiencia renal', 'category': 'Nutrición'},
    {'url': 'https://www.youtube.com/watch?v=K-c8Feb1ARk', 'title': 'La MEJOR ALIMENTACIÓN durante la DIÁLISIS | Tipo de dieta en la diálisis | Nutrición y Dietética', 'category': 'Consejos'}
    // Otros videos con sus categorías...
  ];

  // Función para obtener videos según la categoría seleccionada
  List<Widget> _getFilteredVideos() {
    if (_selectedCategory == 'Todos') {
      // Si la categoría es "Todos", devuelve todos los videos
      return _videoData.map((video) => VideoCard(videoUrl: video['url'], videoTitle: video['title'])).toList();
    } else {
      // De lo contrario, filtra por la categoría seleccionada
      return _videoData
          .where((video) => video['category'] == _selectedCategory)
          .map((video) => VideoCard(videoUrl: video['url'], videoTitle: video['title']))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          DropdownButton(
            value: _selectedCategory,
            items: _categories.map((String category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(), // Reemplaza CustomSearchDelegate con tu propia implementación de la clase SearchDelegate
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Implementa aquí la navegación al perfil del usuario
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: _getFilteredVideos(),
            ),
          ),
        ),
      ),
    );
  }
}
