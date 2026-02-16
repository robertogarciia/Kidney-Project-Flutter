import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha

class videosPacient extends StatefulWidget {
  final String relatedPatientId;

  const videosPacient({Key? key, required this.relatedPatientId}) : super(key: key);

  @override
  _videosPacientState createState() => _videosPacientState();
}

class _videosPacientState extends State<videosPacient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Métode para obtenir els videos vistos filtrats per relatedPatientId
  Stream<QuerySnapshot> getVideosVistos() {
    return _firestore
        .collection('Usuarios')
        .doc(widget.relatedPatientId)
        .collection('videosVistos')
        .where('visto', isEqualTo: true)
        .snapshots();
  }

  // Método per a  formatejar el timestamp
  String formatTimestamp(Timestamp timestamp) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy, HH:mm');
    return formatter.format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF603D),

        title: Text('Vídeos visualitzats pel pacient'),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getVideosVistos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hi ha vídeos vistos.'));
          }

          var videos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var video = videos[index];
              Timestamp timestamp = video['timestampVisto'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                color: Color(0xFFFF603D),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    video['Titol'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Letra blanca
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vist el: ${formatTimestamp(timestamp)}',
                        style: TextStyle(fontSize: 18,color: Colors.white), // Letra blanca
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
