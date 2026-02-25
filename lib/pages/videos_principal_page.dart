import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/pages/videosPacient.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Videos extends StatefulWidget {
  final String userId;
  const Videos({Key? key, required this.userId}) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  String? selectedCategory;
  String searchQuery = '';
  bool isFamiliar = false;
  String? relatedPatientId;
  bool mostrarImagen = false;

  // Controladores persistentes por título de video
  final Map<String, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .get();

      final data = userDoc.data();
      if (data == null) return;

      if (data['tipo'] == 'Familiar') {
        if (!mounted) return;
        setState(() => isFamiliar = true);

        final relacionSnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('relacionFamiliarPaciente')
            .limit(1)
            .get();

        if (relacionSnapshot.docs.isNotEmpty) {
          final dniPaciente = relacionSnapshot.docs.first.data()['DniPaciente'];
          await _getPatientIdFromDNI(dniPaciente);
        }
      }
    } catch (e) {
      debugPrint("Error verificando tipo usuario: $e");
    }
  }

  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    try {
      final query = await FirebaseFirestore.instance
          .collectionGroup('dadesPersonals')
          .where('Dni', isEqualTo: dniPaciente)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final userRef = doc.reference.parent.parent;

        if (userRef != null && mounted) {
          setState(() => relatedPatientId = userRef.id);
        }
      }
    } catch (e) {
      debugPrint("Error buscando paciente por DNI: $e");
    }
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
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => mostrarImagen = false);
      }
    } catch (e) {
      debugPrint("Error marcando como visto: $e");
    }
  }

  Stream<QuerySnapshot> _videosStream() {
    Query query = FirebaseFirestore.instance.collection('Videos');

    if (selectedCategory != null) {
      query = query.where('Categoria', isEqualTo: selectedCategory);
    }

    return query.snapshots();
  }

  @override
  void dispose() {
    // 🔥 IMPORTANTE: cerrar controllers
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
          if (isFamiliar)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: relatedPatientId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => videosPacient(
                                relatedPatientId: relatedPatientId!),
                          ),
                        );
                      },
                child: const Text("Vídeos pacient"),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: "Buscar per títol...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                                YoutubePlayerController.convertUrlToId(
                                    data['url']);

                            if (videoId != null) {
                              _controllers[data['Titol']] =
                                  YoutubePlayerController.fromVideoId(
                                videoId: videoId,
                                autoPlay: false,
                                params: const YoutubePlayerParams(
                                  showControls: true,
                                  showFullscreenButton: false, // 🔥 SOLUCIÓN
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
                                    maxWidth:
                                        isDesktop ? 700 : double.infinity),
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
          ],
        ),
      ),
    );
  }
}
