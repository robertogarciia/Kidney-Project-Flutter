import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoCategoria;
  final Function(String) onMarkAsViewed;
  final String userId;
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

class _VideoCardState extends State<VideoCard> {
  bool _isExpanded = false;
  late YoutubePlayerController _controller;
  bool _isViewed = false;
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
    _checkIfViewed();
  }
  Future<void> _checkIfViewed() async {
    final doc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('videosVistos')
        .doc(widget.videoTitle)
        .get();

    if (doc.exists) {
      setState(() {
        _isViewed = true; // si existe en Firestore, marcamos como visto
      });
    }
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
                onPressed: _isViewed
                    ? null // si ya fue visto, desactiva el botón
                    : () async {
                  await widget.onMarkAsViewed(widget.videoTitle);
                  setState(() {
                    _isViewed = true; // cambia el estado local para actualizar UI
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isViewed ? Colors.green : Colors.white,
                  foregroundColor: _isViewed ? Colors.white : Color(0xFFFF603D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: _isViewed ? Colors.white : Color(0xFFFF603D)),
                    SizedBox(width: 10),
                    Text(
                      _isViewed ? 'Vist' : 'Marcar com vist',
                      style: TextStyle(color: _isViewed ? Colors.white : Color(0xFFFF603D)),
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
