import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/info_card.dart';

class noticiesPage extends StatefulWidget {
  final String userId;

  const noticiesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _noticiesPageState createState() => _noticiesPageState();
}

class _noticiesPageState extends State<noticiesPage> {
  String? selectedCategory;
  String searchQuery = '';

  void resetFilter() {
    setState(() {
      selectedCategory = null;
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD53D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Noticies',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 22),

                // Buscador
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
                        hintText: 'Buscar per títol...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      hint: Text('Seleccionar categoría'),
                      value: selectedCategory,
                      items: ['Salud', 'Investigación'].map((String value) {
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
                    ElevatedButton(
                      onPressed: resetFilter,
                      child: Text('Restablir filtres'),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Mostrar noticias
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Noticies')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('No hay noticias disponibles');
                    }

                    // Filtrar noticies per categoría i cerca
                    List<DocumentSnapshot> filteredNews = snapshot.data!.docs
                        .where((doc) {
                      bool matchesCategory = selectedCategory == null ||
                          doc['Categoria'] == selectedCategory;
                      bool matchesSearch = doc['Titol'] != null &&
                          doc['Titol'].toLowerCase().contains(searchQuery);
                      return matchesCategory && matchesSearch;
                    })
                        .toList();

                    if (filteredNews.isEmpty) {
                      return Text(
                          'No se encontraron noticias con los filtros aplicados.');
                    }

                    return Column(
                      children: filteredNews.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                        return InfoCard(
                          infoUrl: data['url'],
                          infoTitle: data['Titol'],
                          infoDescription: data['Descripcio'],
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
