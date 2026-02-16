import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/RankingPage.dart';
import 'package:kidneyproject/pages/menu_joc.dart';

class RankingPageNoHabilidades extends StatefulWidget {
  final String userId;

  const RankingPageNoHabilidades({Key? key, required this.userId})
      : super(key: key);

  @override
  _RankingPageNoHabilidadesState createState() =>
      _RankingPageNoHabilidadesState();
}

class _RankingPageNoHabilidadesState extends State<RankingPageNoHabilidades> {
  List<Map<String, dynamic>> userInfo = [];

  Future<void> _fetchUserInfo() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Usuarios').get();

      List<Map<String, dynamic>> fetchedUserInfo = [];

      for (var doc in snapshot.docs) {
        String userId = doc.id;

        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .collection('trivial')
            .doc('datos')
            .get();

        var maxPuntuacionNoHabilitats = 0;

        if (userData.exists && userData.data() != null) {
          maxPuntuacionNoHabilitats = (userData.data()
                  as Map<String, dynamic>)['maxPuntuacionNoHabilitats'] ??
              0;
        }

        var nombreUsuario = doc['Nombre'] ?? 'No disponible';

        fetchedUserInfo.add({
          'Nombre': nombreUsuario,
          'maxPuntuacionNoHabilitats': maxPuntuacionNoHabilitats,
        });
      }

      fetchedUserInfo.sort((a, b) => b['maxPuntuacionNoHabilitats']
          .compareTo(a['maxPuntuacionNoHabilitats']));

      if (fetchedUserInfo.length > 10) {
        fetchedUserInfo = fetchedUserInfo.sublist(0, 10);
      }

      setState(() {
        userInfo = fetchedUserInfo;
      });
    } catch (error) {
      print('Error al obtener los datos de los usuarios: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Ranking'),
        backgroundColor: Color.fromRGBO(66, 61, 242, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuJoc(userId: widget.userId),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Fondo suave
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userInfo.isEmpty)
                Center(
                  child: CircularProgressIndicator(),
                )
              else ...[
                Row(
                  children: [
                    Image.asset(
                      'lib/images/ranking.png',
                      width: 28, // Ajusta el tamaño según lo que necesites
                      height: 28,
                    ),
                    const SizedBox(
                        width: 10), // Espacio entre la imagen y el texto
                    Text(
                      'Top 10 Usuaris, joc sense habilitats',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(66, 61, 242, 1.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: userInfo.length,
                    itemBuilder: (context, index) {
                      var user = userInfo[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                        elevation: 5, // Sombra suave
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Row(
                            children: [
                              Text(
                                '${index + 1}. ', // Número de posición
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromRGBO(66, 61, 242, 1.0),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  user['Nombre'], // Nombre de usuario
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Para no desbordar el texto
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Puntuació: ${user['maxPuntuacionNoHabilitats']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Color.fromRGBO(66, 61, 242, 1.0),
                            radius: 25,
                            child: Icon(
                              Icons.account_circle,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RankingPage(userId: widget.userId),
            ),
          );
        },
        icon: Image.asset(
          'lib/images/ranking.png',
          width: 24,
          height: 24,
        ),
        //texto color blanco
        label: Text(
          'Habilitats',
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Color.fromRGBO(66, 61, 242, 1.0),
      ),
    );
  }
}
