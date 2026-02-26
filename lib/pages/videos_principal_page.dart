import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/pages/videosPacient.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Videos extends StatefulWidget {
  final String userId;
  final bool isFamiliar; // recibido desde menu_principal
  final String? relatedPatientId; // recibido desde menu_principal

  const Videos({
    Key? key,
    required this.userId,
    this.isFamiliar = false,
    this.relatedPatientId,
  }) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  String? selectedCategory = 'Totes';
  String searchQuery = '';
  bool mostrarImagen = false;

  final List<String> categorias = ['Nutrició', 'Diàlisis'];
  final Map<String, YoutubePlayerController> _controllers = {};

  Stream<QuerySnapshot> _videosStream() {
    Query query = FirebaseFirestore.instance.collection('Videos');

    if (selectedCategory != null && selectedCategory != 'Totes') {
      query = query.where('Categoria', isEqualTo: selectedCategory);
    }

    return query.snapshots();
  }

  Future<void> marcarComoVisto(String videoTitle) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('videosVistos')
          .doc(videoTitle);

      final snapshot = await ref.get();

      if (!snapshot.exists) {
        await ref.set({
          'Titol': videoTitle,
          'visto': true,
          'timestampVisto': FieldValue.serverTimestamp(),
        });

        final coinsRef = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('trivial')
            .doc('datos');

        await coinsRef.set(
          {'coins': FieldValue.increment(10)},
          SetOptions(merge: true),
        );

        if (!mounted) return;
        setState(() => mostrarImagen = true);
        await Future.delayed(const Duration(seconds: 0));
        if (mounted) setState(() => mostrarImagen = false);
      }
    } catch (e) {
      debugPrint("Error marcando como visto: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF603D),
        title: const Text("Vídeos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isFamiliar && widget.relatedPatientId != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => videosPacient(
                        relatedPatientId: widget.relatedPatientId!,
                      ),
                    ),
                  );
                },
                child: const Text("Vídeos pacient"),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Buscador + filtros
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() => searchQuery = value.toLowerCase());
                        },
                        decoration: InputDecoration(
                          hintText: "Buscar per títol...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Seleccionar Categoria:",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'Totes',
                                  child: Text('Totes'),
                                ),
                                ...categorias.map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value ?? 'Totes';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                selectedCategory = 'Totes';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Restablir filtres',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              StreamBuilder<QuerySnapshot>(
                stream: _videosStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final docs = snapshot.data!.docs;
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['Titol']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  return Column(
                    children: filtered.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (!_controllers.containsKey(data['Titol'])) {
                        final videoId =
                            YoutubePlayerController.convertUrlToId(data['url']);
                        if (videoId != null) {
                          _controllers[data['Titol']] =
                              YoutubePlayerController.fromVideoId(
                            videoId: videoId,
                            autoPlay: false,
                            params: const YoutubePlayerParams(
                              showControls: true,
                              showFullscreenButton: false,
                            ),
                          );
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: isDesktop ? 700 : double.infinity),
                            child: VideoCard(
                              videoUrl: data['url'],
                              videoTitle: data['Titol'],
                              videoCategoria: data['Categoria'],
                              userId: widget.userId,
                              onMarkAsViewed: marcarComoVisto,
                              isDesktop: isDesktop,
                              controller: _controllers[data['Titol']]!,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
