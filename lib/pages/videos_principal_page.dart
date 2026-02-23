import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/video_card.dart';
import 'package:kidneyproject/pages/videosPacient.dart';

class Videos extends StatefulWidget {
  final String userId;

  const Videos({Key? key, required this.userId}) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late Future<List<DocumentSnapshot>> _videosFuture;

  String? selectedCategory;
  String searchQuery = '';

  bool isFamiliar = false;
  String? relatedPatientId;
  bool mostrarImagen = false;

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadVideos();
    _checkUserType();
  }

  // 🔹 Cargar vídeos UNA sola vez
  Future<List<DocumentSnapshot>> _loadVideos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Videos').get();
    return snapshot.docs;
  }

  // 🔹 Verificar tipo usuario
  Future<void> _checkUserType() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    final data = userDoc.data();
    if (data == null) return;

    if (data['tipo'] == 'Familiar') {
      setState(() => isFamiliar = true);

      final relacionSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('relacionFamiliarPaciente')
          .get();

      if (relacionSnapshot.docs.isNotEmpty) {
        final dniPaciente = relacionSnapshot.docs.first.data()['DniPaciente'];
        await _getPatientIdFromDNI(dniPaciente);
      }
    }
  }

  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    final users = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var user in users.docs) {
      final personal =
          await user.reference.collection('dadesPersonals').doc('dades').get();

      if (personal.exists && personal.data()?['Dni'] == dniPaciente) {
        setState(() => relatedPatientId = user.id);
        break;
      }
    }
  }

  // 🔹 Marcar como visto
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

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final data = await transaction.get(coinsRef);

          if (!data.exists) {
            transaction.set(coinsRef, {'coins': 10});
          } else {
            int coins = data.get('coins') ?? 0;
            transaction.update(coinsRef, {'coins': coins + 10});
          }
        });

        setState(() => mostrarImagen = true);

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          setState(() => mostrarImagen = false);
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 15),

              // 🔎 Buscador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
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

              // 📂 Filtros
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    hint: const Text("Categoria"),
                    value: selectedCategory,
                    items: ['Diàlisis', 'Nutrició']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        searchQuery = '';
                      });
                    },
                    child: const Text("Restablir"),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // 📺 Lista vídeos
              Expanded(
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _videosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No hi ha vídeos"));
                    }

                    final filtered = snapshot.data!.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final matchesCategory = selectedCategory == null ||
                          data['Categoria'] == selectedCategory;

                      final matchesSearch = data['Titol']
                              ?.toString()
                              .toLowerCase()
                              .contains(searchQuery) ??
                          false;

                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text("No se encontraron vídeos"));
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final data =
                            filtered[index].data() as Map<String, dynamic>;

                        return VideoCard(
                          videoUrl: data['url'],
                          videoTitle: data['Titol'],
                          videoCategoria: data['Categoria'],
                          userId: widget.userId,
                          onMarkAsViewed: marcarComoVisto,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 🎉 Imagen +10 puntos
          if (mostrarImagen)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Image.asset(
                  'assets/images/+10Puntos.png',
                  width: 250,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
