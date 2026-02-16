import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/lesMevesDadesMediques.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class LesMevesDades extends StatefulWidget {
  final String userId;

  const LesMevesDades({Key? key, required this.userId}) : super(key: key);

  @override
  _LesMevesDadesState createState() => _LesMevesDadesState();
}

class _LesMevesDadesState extends State<LesMevesDades> {
  late Future<List<DocumentSnapshot>> _userData;
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    _userData = _loadUserData();
  }
// funció per carregar les dades
  Future<List<DocumentSnapshot>> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('tipusDeUsuario')
        .doc('tipus')
        .get();

    final userData = userDoc.data() as Map<String, dynamic>;
// si el tipus és familiar carrega les dades familiars
    if (userData['tipo'] == 'Familiar') {
      final personalData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesFamiliars')
          .doc('dades')
          .get();

      final generalData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .get();

      return [personalData, generalData];
      // si el tipus és pacient carrega les dades personals
    } else if (userData['tipo'] == 'Pacient') {
      final personalData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesPersonals')
          .doc('dades')
          .get();
      final generalData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .get();
      return [personalData, generalData];
    }

    return [];
  }

  void _toggleEdit(String field) {
    setState(() {
      _isEditing[field] = !_isEditing[field]!;
    });
  }
// funció per desar les dades
  Future<void> _saveData(String field) async {
    String value = _controllers[field]!.text;
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('dadesPersonals')
        .doc('dades')
        .update({field: value});

    // Forzar recarga de la vista
    setState(() {
      _isEditing[field] = false;
      // Recarga de les dades
      _userData = _loadUserData();
    });

    // Mostrar missatge de actualizació exitosa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('S\'ha actualitzat correctament'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MenuPrincipal(userId: widget.userId)),
                  (route) => false,
            );
          },
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty || !snapshot.data![0].exists || !snapshot.data![1].exists) {
            return const Center(child: Text('No es troben dades.'));
          }

          var personalData = snapshot.data![0].data() as Map<String, dynamic>;
          var generalData = snapshot.data![1].data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Dades Personals",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                if (generalData['Nombre']?.isNotEmpty ?? false)
                  _buildEditableTile('Nom:', generalData['Nombre']!, 'Nombre'),
                if (generalData['Email']?.isNotEmpty ?? false)
                  _buildEditableTile('Correu:', generalData['Email']!, 'Email'),
                if (personalData['Dni']?.isNotEmpty ?? false)
                  _buildEditableTile('DNI:', personalData['Dni']!, 'Dni'),
                if (personalData['DniFamiliar']?.isNotEmpty ?? false)
                  _buildEditableTile('Dni Familiar:', personalData['DniFamiliar']!, 'DniFamiliar'),
                if (personalData['DniPacient']?.isNotEmpty ?? false)
                  _buildEditableTile('Dni Pacient:', personalData['DniPacient']!, 'DniPacient'),
                if (personalData['dataNaixement']?.isNotEmpty ?? false)
                  _buildEditableTile('Data de naixement:', personalData['dataNaixement']!, 'dataNaixement'),
                if (personalData['telefon']?.isNotEmpty ?? false)
                  _buildEditableTile('Telefon:', personalData['telefon']!, 'telefon'),
                if (personalData['adreca']?.isNotEmpty ?? false)
                  _buildEditableTile('Direcció:', personalData['adreca']!, 'adreca'),
                if (personalData['poblacio']?.isNotEmpty ?? false)
                  _buildEditableTile('Població:', personalData['poblacio']!, 'poblacio'),
                if (personalData['codiPostal']?.isNotEmpty ?? false)
                  _buildEditableTile('Codi Postal:', personalData['codiPostal']!, 'codiPostal'),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LesMevesDadesMediques(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Veure dades mèdiques pacient',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableTile(String title, String value, String field) {
    _controllers.putIfAbsent(field, () => TextEditingController(text: value));
    _isEditing.putIfAbsent(field, () => false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 6),
                  _isEditing[field]!
                      ? TextField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      hintText: 'Introduce el nuevo valor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        // El valor se actualiza en el controlador de inmediato
                      });
                    },
                  )
                      : Text(value, style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7))),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _isEditing[field]! ? Icons.save : Icons.edit,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                if (_isEditing[field]!) {
                  _saveData(field);
                } else {
                  _toggleEdit(field);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
