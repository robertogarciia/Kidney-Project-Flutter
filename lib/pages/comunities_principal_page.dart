import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';

class Comunities extends StatefulWidget {
  final String userId;

  const Comunities({Key? key, required this.userId}) : super(key: key);

  @override
  State<Comunities> createState() => _ComunitiesState();
}

class _ComunitiesState extends State<Comunities> {
  TextEditingController _searchController = TextEditingController();
  String _categoriaFiltrada = 'Totes';

  Stream<QuerySnapshot> obtenerChats() {
    return FirebaseFirestore.instance
        .collection('Chats')
        .where('Participants', arrayContains: widget.userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Future<String> obtenerNombreOtroParticipante(String chatId) async {
    var chat = await FirebaseFirestore.instance.collection('Chats').doc(chatId).get();
    var participants = chat['Participants'];

    String otherUserId = participants.firstWhere((id) => id != widget.userId);

    var userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(otherUserId).get();

    if (userDoc.exists) {
      return userDoc['Nombre'] ?? 'Usuari';
    } else {
      var personalDoc = await FirebaseFirestore.instance.collection('personalMèdic').doc(otherUserId).get();
      if (personalDoc.exists) {
        return personalDoc['Nom'] ?? 'Personal';
      } else {
        return 'No trobat';
      }
    }
  }

  Future<String?> obtenirCategoriaDelContacte(String chatId) async {
    var chat = await FirebaseFirestore.instance.collection('Chats').doc(chatId).get();
    var participants = chat['Participants'];
    String otherUserId = participants.firstWhere((id) => id != widget.userId);

    var personalDoc = await FirebaseFirestore.instance.collection('personalMèdic').doc(otherUserId).get();
    if (personalDoc.exists) {
      return personalDoc['Categoria'];
    }
    return 'Altres';
  }

  Future<void> mostrarSeleccionCrearXat(BuildContext context) async {
    final relationsSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('relacióUsuariPersonal')
        .get();

    List<Map<String, dynamic>> relacions = [];

    for (final doc in relationsSnapshot.docs) {
      final data = doc.data();
      final ref = data['idPersonal'] as DocumentReference?;
      if (ref != null) {
        final personalSnap = await ref.get();
        final personalData = personalSnap.data() as Map<String, dynamic>?;
        if (personalData != null) {
          relacions.add({
            'id': doc.id,
            'categoria': personalData['Categoria'] ?? 'No disponible',
            'nom': personalData['Nom'] ?? 'No disponible',
            'idPersonal': ref.id,
          });
        }
      }
    }

    List<String> idsPersonasConChat = [];
    for (final r in relacions) {
      final idAltre = r['idPersonal'];
      final participants = [widget.userId, idAltre]..sort();
      final chatId = participants.join("_");
      final chatRef = FirebaseFirestore.instance.collection('Chats').doc(chatId);
      final chatExists = await chatRef.get();
      if (chatExists.exists) idsPersonasConChat.add(idAltre);
    }

    String? categoriaSeleccionada;
    Map<String, dynamic>? personalSeleccionat;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          final personalFiltrat = categoriaSeleccionada == null
              ? relacions
              : relacions.where((e) => e['categoria'] == categoriaSeleccionada).toList();

          final personalSinChat = personalFiltrat.where((p) => !idsPersonasConChat.contains(p['idPersonal'])).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Nou xat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Categoria (opcional)'),
                  value: categoriaSeleccionada,
                  items: [null, ...relacions.map((e) => e['categoria'] as String).toSet()]
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat ?? 'Totes'),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      categoriaSeleccionada = value;
                      personalSeleccionat = null;
                    });
                  },
                ),
                SizedBox(height: 12),
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: Text('Selecciona personal'),
                  value: personalSeleccionat,
                  items: personalSinChat
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p['nom']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      personalSeleccionat = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: personalSeleccionat == null
                      ? null
                      : () async {
                    final idAltre = personalSeleccionat!['idPersonal'];
                    final participants = [widget.userId, idAltre]..sort();
                    final chatId = participants.join("_");
                    final chatRef = FirebaseFirestore.instance.collection('Chats').doc(chatId);
                    final chatExists = await chatRef.get();

                    if (chatExists.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Este chat ja existeix.')),
                      );
                    } else {
                      await chatRef.set({
                        'Participants': participants,
                        'ultimMissatge': '',
                        'lastTimestamp': Timestamp.now()
                      });

                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chatId: chatId,
                            userId: widget.userId,
                            otherUserName: personalSeleccionat!['nom'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Iniciar xat"),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Comunitats'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cerca per nom...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['Totes', 'Personal', 'Alimentació'].map((categoria) {
                      bool isSelected = _categoriaFiltrada == categoria;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(categoria),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _categoriaFiltrada = categoria;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: obtenerChats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  var chats = snapshot.data!.docs;

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(chats.map((chat) async {
                      final chatId = chat.id;
                      final otherName = await obtenerNombreOtroParticipante(chatId);
                      final categoria = await obtenirCategoriaDelContacte(chatId);
                      return {
                        'chat': chat,
                        'otherUserName': otherName,
                        'categoria': categoria ?? 'Altres',
                      };
                    })),
                    builder: (context, userDataSnapshot) {
                      if (!userDataSnapshot.hasData) return Center(child: CircularProgressIndicator());

                      var filtrats = userDataSnapshot.data!
                          .where((item) {
                        final matchCategoria = _categoriaFiltrada == 'Totes' || item['categoria'] == _categoriaFiltrada;
                        final matchText = item['otherUserName']
                            .toString()
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                        return matchCategoria && matchText;
                      })
                          .toList();

                      if (filtrats.isEmpty) return Center(child: Text('No s\'han trobat xats.'));

                      return ListView.builder(
                        itemCount: filtrats.length,
                        itemBuilder: (context, index) {
                          var item = filtrats[index];
                          var chat = item['chat'];
                          var chatId = chat.id;
                          var otherUserName = item['otherUserName'];
                          var lastMessage = chat['ultimMissatge'] ?? 'No hi ha missatges encara';
                          var lastTimestamp = chat['lastTimestamp']?.toDate() ?? DateTime.now();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                title: Text(
                                  otherUserName,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                                subtitle: Text(
                                  "últim missatge: $lastMessage",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black87),
                                ),
                                trailing: Text(
                                  '${lastTimestamp.hour.toString().padLeft(2, '0')}:${lastTimestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        chatId: chatId,
                                        userId: widget.userId,
                                        otherUserName: otherUserName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarSeleccionCrearXat(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add_comment),
        tooltip: "Nou xat",
      ),
    );
  }
}
