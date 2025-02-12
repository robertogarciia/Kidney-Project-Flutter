import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/lesMevesDades.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class LesMevesDadesMediques extends StatefulWidget {
  final String userId;

  const LesMevesDadesMediques({Key? key, required this.userId})
      : super(key: key);

  @override
  _LesMevesDadesMediquesState createState() => _LesMevesDadesMediquesState();
}

class _LesMevesDadesMediquesState extends State<LesMevesDadesMediques> {
  late Future<List<DocumentSnapshot>> _userData;
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> _isEditing = {};
  Map<String, String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _userData = _loadUserData();
  }
Future<List<DocumentSnapshot>> _loadUserData() async {
  print("Cargando datos del usuario: ${widget.userId}");

  final userDoc = await FirebaseFirestore.instance
      .collection('Usuarios')
      .doc(widget.userId)
      .collection('tipusDeUsuario')
      .doc('tipus')
      .get();

  final userData = userDoc.data() as Map<String, dynamic>?;

  if (userData == null) {
    print("Error: No se encontró el documento de tipusDeUsuario para ${widget.userId}");
    return [];
  }

  print("Tipo de usuario: ${userData['tipo']}");

  if (userData['tipo'] == 'Familiar') {
    final relatedPatientDocs = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('relacionFamiliarPaciente')
        .get();

    print("Documentos en relacionFamiliarPaciente: ${relatedPatientDocs.docs.length}");

    if (relatedPatientDocs.docs.isEmpty) {
      print("Error: No se encontraron pacientes relacionados para este familiar.");
      return [];
    }

    final relatedPatientData = relatedPatientDocs.docs.first.data();
    final dniPaciente = relatedPatientData['DniPaciente'];
    print("DNI del paciente relacionado: $dniPaciente");

    return await _loadPatientData(dniPaciente);
  } else if (userData['tipo'] == 'Pacient') {
    print("Cargando datos médicos para el paciente...");

    final personalData = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('dadesMediques')
        .doc('datos')
        .get();

    final generalData = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .get();

    return [personalData, generalData];
  }

  print("Error: Tipo de usuario desconocido.");
  return [];
}

Future<List<DocumentSnapshot>> _loadPatientData(String dniPaciente) async {
  print("Buscando datos del paciente con DNI: $dniPaciente");

  final usersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

  for (var userDoc in usersSnapshot.docs) {
    // Buscar en 'dadesPersonal' primero
    final personalDataSnapshot = await userDoc.reference
        .collection('dadesPersonals') // Aquí cambiamos a 'dadesPersonal'
        .doc('dades')
        .get();

    if (personalDataSnapshot.exists) {
      final personalData = personalDataSnapshot.data();
      print("Datos personales encontrados en usuario ${userDoc.id}");

      if (personalData?['Dni'] == dniPaciente) {
        print("Paciente encontrado con DNI en 'dadesPersonal'. Cargando datos médicos...");

        // Ahora cargamos 'dadesMediques'
        final medicalDataSnapshot = await userDoc.reference
            .collection('dadesMediques')
            .doc('datos')
            .get();

        if (!medicalDataSnapshot.exists) {
          print("Error: No se encontraron dadesMediques para el paciente con DNI: $dniPaciente");
          return [];
        }

        final generalDataSnapshot = await userDoc.reference.get();
        return [medicalDataSnapshot, generalDataSnapshot];
      }
    }
  }

  print("Error: No se encontró un paciente con el DNI: $dniPaciente en 'dadesPersonal'");
  return [];
}

  Future<void> _saveChanges(String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesMediques')
          .doc('datos')
          .update({field: value});

      setState(() {
        _isEditing[field] = false;
        _userData = _loadUserData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dades actualitzades correctament.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualitzar les dades.')),
      );
    }
  }

  TextEditingController _getController(String field, String value) {
    if (!_controllers.containsKey(field)) {
      _controllers[field] = TextEditingController(text: value);
    }
    return _controllers[field]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MenuPrincipal(userId: widget.userId)),
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No s'han trobat dades."));
          }

          var data = snapshot.data![0].data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Dades Mèdiques",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoTile('Alçada:', data['alcada'] ?? 'No disponible', 'alcada'),
                _buildInfoTile('Pes:', data['pes'] ?? 'No disponible', 'pes'),
                _buildInfoTile('Estat:', data['estat'] ?? 'No disponible', 'estat'),
                _buildInfoTile('Estadio', data['estadio']?? 'No disponible', 'estadio'),
                _buildInfoTile('Diabètic', data['diabetic']?? 'No disponible', 'diabetic'),
                _buildInfoTile('Hipertens', data['hipertens']?? 'No disponible', 'hipertens'),
                _buildInfoTile('Pacient Expert', data['pacientExpert']?? 'No disponible', 'pacientExpert'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LesMevesDades(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Veure dades personals',
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

   Widget _buildInfoTile(String title, String value, String field) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _isEditing[field] == true
                      ? TextField(
                          controller: _getController(field, value),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Introduiex un valor',
                          ),
                          onSubmitted: (_) => _saveChanges(field, _controllers[field]?.text ?? ''), 
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                ],
              ),
            ),
            // Icono de edición
            IconButton(
              icon: Icon(
                _isEditing[field] == true ? Icons.save : Icons.edit,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                if (_isEditing[field] == true) {
                  _saveChanges(field, _controllers[field]?.text ?? '');
                } else {
                  setState(() {
                    _isEditing[field] = true; 
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}