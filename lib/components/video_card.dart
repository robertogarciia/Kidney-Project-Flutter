import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoCategoria;
  final Function(String) onMarkAsViewed;
  final String userId;
  final bool isDesktop;
  final YoutubePlayerController controller;

  const VideoCard({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoCategoria,
    required this.onMarkAsViewed,
    required this.userId,
    required this.controller,
    this.isDesktop = false,
  }) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isExpanded = false;
  bool _isViewed = false;

  @override
  void initState() {
    super.initState();
    _checkIfViewed();
  }

  Future<void> _checkIfViewed() async {
    final doc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('videosVistos')
        .doc(widget.videoTitle)
        .get();

    if (doc.exists && mounted) {
      setState(() => _isViewed = true);
    }
  }

  Future<void> _openYoutube() async {
    final Uri url = Uri.parse(widget.videoUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoHeight = widget.isDesktop ? 320.0 : 270.0;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Card(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10), // 🔥 más ancho
        color: const Color(0xFFFF603D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // 🔥 más espacio interno
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.videoTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: widget.isDesktop ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              if (_isExpanded)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: videoHeight,
                    child: YoutubePlayer(controller: widget.controller),
                  ),
                ),

              const SizedBox(height: 14),

              // 🔥 NUEVO BOTÓN YOUTUBE
              ElevatedButton.icon(
                onPressed: _openYoutube,
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Ver vídeo en YouTube',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔥 BOTÓN MARCAR COMO VISTO
              ElevatedButton(
                onPressed: _isViewed
                    ? null
                    : () async {
                        await widget.onMarkAsViewed(widget.videoTitle);
                        if (mounted) setState(() => _isViewed = true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isViewed ? Colors.green : Colors.white,
                  foregroundColor:
                      _isViewed ? Colors.white : const Color(0xFFFF603D),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: _isViewed ? Colors.white : const Color(0xFFFF603D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isViewed ? 'Vist' : 'Marcar com vist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            _isViewed ? Colors.white : const Color(0xFFFF603D),
                      ),
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
