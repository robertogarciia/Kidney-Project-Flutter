import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Widget que representa una tarjeta de video con título, reproducción y botón de "visto"
class VideoCard extends StatefulWidget {
  final String videoUrl; // URL del video de YouTube
  final String videoTitle; // Título del video
  final String
      videoCategoria; // Categoría del video (no se usa directamente aquí)
  final Function(String)
      onMarkAsViewed; // Callback que se llama cuando se marca como visto
  final String userId; // ID del usuario para guardar estado en Firestore

  const VideoCard({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoCategoria,
    required this.userId,
    required this.onMarkAsViewed,
  }) : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

// Estado del widget VideoCard
class _VideoCardState extends State<VideoCard> {
  bool _isExpanded =
      false; // Controla si el video está expandido (visible) o no
  late YoutubePlayerController
      _controller; // Controlador para el reproductor de YouTube
  bool _isViewed = false; // Indica si el usuario ya ha visto el video

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador de YouTube con el ID del video extraído de la URL
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: false, // No reproducir automáticamente
        mute: false, // Sonido activado
      ),
    );

    // Comprueba si el video ya fue marcado como visto en Firestore
    _checkIfViewed();
  }

  // Función que verifica en Firestore si el usuario ya vio el video
  Future<void> _checkIfViewed() async {
    final doc = await FirebaseFirestore.instance
        .collection('Usuarios') // Colección de usuarios
        .doc(widget.userId) // Documento del usuario actual
        .collection('videosVistos') // Subcolección de videos vistos
        .doc(
            widget.videoTitle) // Documento del video (usando el título como ID)
        .get();

    if (doc.exists) {
      setState(() {
        _isViewed = true; // Si existe, marca el video como visto
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera recursos del controlador de YouTube
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color(0xFFFF603D), // Color naranja de la tarjeta
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded =
                !_isExpanded; // Expande o colapsa el video al tocar la tarjeta
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título del video
              Text(
                widget.videoTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // Animación para mostrar/ocultar el reproductor de YouTube
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: SizedBox(), // Estado colapsado (no se muestra)
                secondChild: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true, // Barra de progreso
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
              SizedBox(height: 10),

              // Botón para marcar como visto
              ElevatedButton(
                onPressed: _isViewed
                    ? null // Si ya se vio, el botón se desactiva
                    : () async {
                        await widget.onMarkAsViewed(widget
                            .videoTitle); // Llama a la función pasada por el padre
                        setState(() {
                          _isViewed =
                              true; // Actualiza el estado local para cambiar el color y texto
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isViewed
                      ? Colors.green
                      : Colors.white, // Verde si ya fue visto
                  foregroundColor: _isViewed
                      ? Colors.white
                      : Color(0xFFFF603D), // Texto naranja si no fue visto
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Bordes redondeados
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check,
                        color: _isViewed
                            ? Colors.white
                            : Color(0xFFFF603D)), // Icono check
                    SizedBox(width: 10),
                    Text(
                      _isViewed
                          ? 'Vist'
                          : 'Marcar com vist', // Cambia el texto según el estado
                      style: TextStyle(
                          color: _isViewed ? Colors.white : Color(0xFFFF603D)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
