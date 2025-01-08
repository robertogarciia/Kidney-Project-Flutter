import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/components/video_card.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  String? selectedCategory;
  String searchQuery = '';  // Para almacenar la consulta de búsqueda

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoose()),
    );
  }

  void resetFilter() {
    setState(() {
      selectedCategory = null;
      searchQuery = '';  // Resetea el término de búsqueda también
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
                backgroundColor: Color(0xFFFF603D), 

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navega hacia atrás en la pila de navegación al presionar el botón
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                // Texto para el título de la página
                Text(
                  'Vídeos',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Buscador mejorado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar por título...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Fila con el filtro y el botón de reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DropdownButton para filtrar por categoría
                    DropdownButton<String>(
                      hint: Text('Seleccionar categoría'),
                      value: selectedCategory,
                      items: ['Diàlisis', 'Nutrició'] // Aquí debes proporcionar las categorías únicas disponibles
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    // Botón de reset para restablecer el filtrado
                    ElevatedButton(
                      onPressed: resetFilter,
                      child: Text('Restablir filtre'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Mostrar videos desde Firebase
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('Videos').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('No hay videos disponibles'); // Maneja el caso de que no haya datos en la colección
                    }

                    // Filtrar los videos por categoría y búsqueda si se han establecido
                    List<DocumentSnapshot> filteredVideos = snapshot.data!.docs
                        .where((doc) {
                          bool matchesCategory = selectedCategory == null || doc['Categoria'] == selectedCategory;
                          bool matchesSearch = doc['Titol'].toLowerCase().contains(searchQuery);
                          return matchesCategory && matchesSearch;
                        })
                        .toList();

                    return Column(
                      children: filteredVideos.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return VideoCard(
                          videoUrl: data['url'], // Obtén la URL del documento
                          videoTitle: data['Titol'],
                          videoCategoria: data['Categoria'], // Obtén el título del documento
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
