import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogrosPage extends StatefulWidget {
  final String userId;
  final bool isFamiliar;
  final String? relatedPatientId;

  const LogrosPage({
    Key? key,
    required this.userId,
    this.isFamiliar = false,
    this.relatedPatientId,
  }) : super(key: key);

  @override
  _LogrosPageState createState() => _LogrosPageState();
}

class _LogrosPageState extends State<LogrosPage> {
  int videosCount = 0;
  int noticiasCount = 0;
  int dietasCount = 0;
  bool isLoading = true;

  Future<void> _fetchLogros() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('Usuarios').doc(widget.userId);

      // Contar videos vistos
      QuerySnapshot videosSnapshot =
          await userRef.collection('videosVistos').get();
      int videos = videosSnapshot.docs.length;

      // Contar noticias vistas
      QuerySnapshot noticiasSnapshot =
          await userRef.collection('noticiesVistes').get();
      int noticias = noticiasSnapshot.docs.length;

      // Contar dietas resum
      QuerySnapshot dietasSnapshot =
          await userRef.collection('resumDietes').get();
      int dietas = dietasSnapshot.docs.length;

      setState(() {
        videosCount = videos;
        noticiasCount = noticias;
        dietasCount = dietas;
        isLoading = false;
      });
    } catch (error) {
      print('Error al obtener los logros: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLogros();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barraWidth = screenWidth * 0.8; // 80% del ancho de pantalla

    return Scaffold(
      appBar: AppBar(
        title: Text('Aconsegueix els èxits d\'avui'),
        backgroundColor: Color.fromRGBO(66, 61, 242, 1.0),
        // Hace que el título y los iconos (flecha) sean blancos
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Texto motivacional ---
                      Text(
                        "A per totes, intenta aconseguir tots els èxits d'avui ⭐",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(66, 61, 242, 1.0),
                        ),
                      ),
                      SizedBox(height: 30), // espacio antes de las barras

                      _buildLogroCard(
                          title: 'Videos vistos',
                          count: videosCount,
                          width: barraWidth),
                      SizedBox(height: 20),
                      _buildLogroCard(
                          title: 'Noticias vistas',
                          count: noticiasCount,
                          width: barraWidth),
                      SizedBox(height: 20),
                      _buildLogroCard(
                          title: 'Dietas completadas',
                          count: dietasCount,
                          width: barraWidth),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLogroCard(
      {required String title, required int count, required double width}) {
    double progress = (count > 10 ? 10 : count) / 10;
    Color barColor =
        count >= 10 ? Colors.green : Color.fromRGBO(66, 61, 242, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: width,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$title: $count/10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(66, 61, 242, 1.0),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 24,
                backgroundColor: Colors.grey[300],
                color: barColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
