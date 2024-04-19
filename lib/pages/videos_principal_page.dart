import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/components/custom_search_delegate.dart';

class Videos extends StatelessWidget {
  const Videos({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Videos'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(), // Reemplaza CustomSearchDelegate con tu propia implementación de la clase SearchDelegate
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Implementa aquí la navegación al perfil del usuario
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                // Afegim la targeta del vídeo
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=3hQdl9lRYL0&t=56s', videoTitle: '¿Qué es la hemodiálisis?'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=xUyEkXXcig8', videoTitle: 'Diálisis'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=OJJ_Xrlq7QI', videoTitle: '¿Cuántos litros de líquido se eliminan durante la hemodiálisis?'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=4TUJ9MAPcuM', videoTitle: 'CONTROVERSIA. Diálisis en casa: ¿Hemodiálisis domiciliaria o Diálisis Peritoneal?'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=P3RJ7tLGZuQ', videoTitle: 'Experiencia de paciente en hemodiálisis domiciliaria'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=KIfjL4O6uQk', videoTitle: 'Consejos sobre cuidados para pacientes en hemodiálisis, IGSS TV 207'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=OHVg-Ymf2zM', videoTitle: '6 recomendaciones y cuidados que debes de tener para tu catéter de hemodiálisis'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=K-c8Feb1ARk', videoTitle: 'La MEJOR ALIMENTACIÓN durante la DIÁLISIS | Tipo de dieta en la diálisis | Nutrición y Dietética'),
                VideoCard(videoUrl: 'https://www.youtube.com/watch?v=Y09v5emN0c0', videoTitle: '🚩Alimentos PROHIBIDOS para la INSUFICIENCIA RENAL Nutricion en pacientes con insuficiencia renal'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
