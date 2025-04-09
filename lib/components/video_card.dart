import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoCategoria;
  final Function(String) onMarkAsViewed;

  const VideoCard({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoCategoria,
    required this.onMarkAsViewed,
  }) : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isExpanded = false;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color(0xFFFF603D),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.videoTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: SizedBox(),
                secondChild: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  widget.onMarkAsViewed(widget.videoTitle); // Llamamos a la función
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFFF603D), backgroundColor: Colors.white, // Color del texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Borde redondeado
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Color(0xFFFF603D)), // Icono de check
                    SizedBox(width: 10),
                    Text(
                      'Marcar com vist',
                      style: TextStyle(color: Color(0xFFFF603D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
