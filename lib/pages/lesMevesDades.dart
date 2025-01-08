import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/lesMevesDadesMediques.dart';
import 'package:kidneyproject/pages/menu_principal.dart'; // Asegúrate de importar correctamente la página de datos médicos.

class LesMevesDades extends StatefulWidget {
  final String userId;

  const LesMevesDades({Key? key, required this.userId}) : super(key: key);

  @override
  _LesMevesDadesState createState() => _LesMevesDadesState();
}

class _LesMevesDadesState extends State<LesMevesDades> {
  late Future<List<DocumentSnapshot>> _userData;
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> _isEditing = {}; // Para manejar el modo de edición de cada campo

  @override
  void initState() {
    super.initState();
    print("Iniciando carga de datos para el usuario: ${widget.userId}");

    _userData = _loadUserData();  // Carga inicial de los datos
  }

  // Cargar los datos del usuario
  Future<List<DocumentSnapshot>> _loadUserData() async {
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

  // Función para guardar cambios
  Future<void> _saveChanges(String field, String value) async {
    try {
      // Actualizando los datos en Firestore
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesPersonals')
          .doc('dades')
          .update({field: value});

      setState(() {
        _isEditing[field] = false; // Desactiva el modo de edición
        _userData = _loadUserData(); // Recarga los datos actualizados
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dades actualiztades correctament.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualitzar les dades.')),
      );
    }
  }

  // Crear un controlador para el campo editable
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
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      // Regresar directamente al menú principal
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

          // Datos recuperados correctamente
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
                _buildInfoTile('Nom:', generalData['Nombre'] ?? 'No disponible', 'Nombre'),
                _buildInfoTile('Correu:', generalData['Email'] ?? 'No disponible', 'Email'),
                _buildInfoTile('Data de naixement:', personalData['dataNaixement'] ?? 'No disponible', 'dataNaixement'),
                _buildInfoTile('Telefon:', personalData['telefon'] ?? 'No disponible', 'telefon'),
                _buildInfoTile('Direcció:', personalData['adreca'] ?? 'No disponible', 'adreca'),
                _buildInfoTile('Població:', personalData['poblacio'] ?? 'No disponible', 'poblacio'),
                _buildInfoTile('Codi Postal:', personalData['codiPostal'] ?? 'No disponible', 'codiPostal'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la página de "Mis Datos Médicos"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LesMevesDadesMediques(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent, // Color del botón
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Veure dades mèdiques',
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
                          onSubmitted: (_) => _saveChanges(field, _controllers[field]?.text ?? ''), // Guardar cambios al presionar Enter
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
                  _saveChanges(field, _controllers[field]?.text ?? ''); // Guardar cambios si está editando
                } else {
                  setState(() {
                    _isEditing[field] = true; // Activar modo de edición
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
