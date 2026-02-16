import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha

class noticiesPacient extends StatefulWidget {
  final String relatedPatientId;

  const noticiesPacient({Key? key, required this.relatedPatientId}) : super(key: key);

  @override
  _noticiesPacientState createState() => _noticiesPacientState();
}

class _noticiesPacientState extends State<noticiesPacient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getNoticiesVistos() {
    return _firestore
        .collection('Usuarios')
        .doc(widget.relatedPatientId)
        .collection('noticiesVistes')
        .where('visto', isEqualTo: true)
        .snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFBC702),
        title: Text('Noticies vistes pel pacient'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getNoticiesVistos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hi ha vídeos vistos.'));
          }

          var noticies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: noticies.length,
            itemBuilder: (context, index) {
              var noticia = noticies[index];
              var timestamp = noticia['timestampVisto'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                color: Color(0xFFFBC702),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    noticia['Titol'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ), // Letra blanca
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vist el: ${formatTimestamp(timestamp)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                  onTap: () {
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
