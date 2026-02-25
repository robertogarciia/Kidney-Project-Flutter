import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    final videoHeight = widget.isDesktop ? 300.0 : 250.0;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: IntrinsicHeight(
        child: Card(
          margin: const EdgeInsets.all(8),
          color: const Color(0xFFFF603D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.videoTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: widget.isDesktop ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (_isExpanded)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: videoHeight,
                      child: YoutubePlayer(controller: widget.controller),
                    ),
                  ),
                const SizedBox(height: 10),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color:
                            _isViewed ? Colors.white : const Color(0xFFFF603D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isViewed ? 'Vist' : 'Marcar com vist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isViewed
                              ? Colors.white
                              : const Color(0xFFFF603D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
