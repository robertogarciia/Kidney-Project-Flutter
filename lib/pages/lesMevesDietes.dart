import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kidneyproject/pages/laMevaDietaDetall.dart';

class lesMevesDietes extends StatefulWidget {
  final String userId;
  final String tipusC;

  const lesMevesDietes({Key? key, required this.userId, required this.tipusC})
      : super(key: key);

  @override
  _lesMevesDietesState createState() => _lesMevesDietesState();
}

class _lesMevesDietesState extends State<lesMevesDietes> {
  String _currentFilter = 'today';
  bool _isDescending = true;
  DateTime? _selectedDate;
  List<QueryDocumentSnapshot> _dietes = [];
  late Future<List<DocumentSnapshot>> _userData;
  String _userType = ''; // Variable para almacenar el tipo de usuario
  bool _mostrarFavorits = false;


  @override
  void initState() {
    super.initState();
    _userData = _loadUserData();
    _fetchDietes();
  }
// funció per carregar les dades de l'usuari
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
    setState(() {
      _userType = userData['tipo']; // Establecemos el tipo de usuario
    });


    print("Tipo de usuario: ${userData['tipo']}");
// Si el tipus d'usuari és 'Familiar', carreguem les dades del pacient relacionat
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
      // Si el tipus d'usuari és 'Pacient', carreguem les dades del pacient
    } else if (userData['tipo'] == 'Pacient') {
      print("Cargando datos resumDietes para el paciente...");

      final resumDietesDocs = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('resumDietes')
          .get();

      if (resumDietesDocs.docs.isEmpty) {
        print("Error: No se encontraron documentos en resumDietes.");
        return [];
      }

      for (var doc in resumDietesDocs.docs) {
        print("Documento en resumDietes: ${doc.id} -> ${doc.data()}");
      }

      return resumDietesDocs.docs;
    }

    print("Error: Tipo de usuario desconocido.");
    return [];
  }
// funció per carregar les dades del pacient relacionat
  Future<List<DocumentSnapshot>> _loadPatientData(String dniPaciente) async {
    print("Buscando datos del paciente con DNI: $dniPaciente");

    final usersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in usersSnapshot.docs) {
      final personalDataSnapshot = await userDoc.reference
          .collection('dadesPersonals') // Aquí buscamos en 'dadesPersonals'
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final personalData = personalDataSnapshot.data();
        print("Datos personales encontrados en usuario ${userDoc.id}");

        if (personalData?['Dni'] == dniPaciente) {
          print("Paciente encontrado con DNI en 'dadesPersonal'. Cargando datos de resumDietes...");

          final resumDietesSnapshot = await userDoc.reference
              .collection('resumDietes') // Aquí cambiamos a 'resumDietes'
              .get();

          if (resumDietesSnapshot.docs.isEmpty) {
            print("Error: No se encontraron documentos en resumDietes para el paciente con DNI: $dniPaciente");
            return [];
          }

          setState(() {
            _dietes = resumDietesSnapshot.docs;
          });

          for (var doc in resumDietesSnapshot.docs) {
            print("Documento en resumDietes: ${doc.id} -> ${doc.data()}");
          }

          return resumDietesSnapshot.docs;
        }
      }
    }

    print("Error: No se encontró un paciente con el DNI: $dniPaciente en 'dadesPersonal'");
    return [];
  }

// funció per obtenir les dietes
  Future<void> _fetchDietes() async {
    final collection = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('resumDietes');

    final DateTime today = DateTime.now();
    Query query = collection;

    if (_currentFilter == 'today') {
      query = query
          .where('fechaCreacion',
          isGreaterThanOrEqualTo:
          Timestamp.fromDate(DateTime(today.year, today.month, today.day)))
          .where('fechaCreacion',
          isLessThan:
          Timestamp.fromDate(DateTime(today.year, today.month, today.day + 1)));
    } else if (_currentFilter == 'calendar' && _selectedDate != null) {
      final DateTime selectedDateStart =
      DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final DateTime selectedDateEnd = selectedDateStart.add(const Duration(days: 1));
      query = query
          .where('fechaCreacion',
          isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDateStart))
          .where('fechaCreacion',
          isLessThan: Timestamp.fromDate(selectedDateEnd));
    }

    final snapshot = await query.get();
    List<QueryDocumentSnapshot> dietes = snapshot.docs;

    if (_mostrarFavorits) {
      dietes = dietes.where((dieta) => dieta['favorito'] == true).toList();
    }

    setState(() {
      _dietes = dietes;
    });
  }

// funció per ordenar les dietes
  void _sortDietes() {
    _dietes.sort((a, b) {
      final puntuacionA = a['puntuacionTotal'] ?? 0;
      final puntuacionB = b['puntuacionTotal'] ?? 0;
      return _isDescending
          ? puntuacionB.compareTo(puntuacionA)
          : puntuacionA.compareTo(puntuacionB);
    });
  }
// funció per mostrar el selector de data
  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _currentFilter = 'calendar';
        _dietes = [];
      });
      _fetchDietes();
    }
  }
// funció per canviar les dietes
  void _toggleDietas() {
    setState(() {
      _currentFilter = _currentFilter == 'today' ? 'all' : 'today';
      _dietes = [];
    });
    _fetchDietes();
  }
// funció per eliminar la dieta
  Future<void> _deleteDiet(String dietaId, int index) async {
    final userRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('resumDietes');

    try {
      await userRef.doc(dietaId).delete();
      setState(() {
        _dietes.removeAt(index);
      });
      _fetchDietes();
    } catch (e) {
      print("Error al eliminar la dieta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_userType == 'Familiar' ? 'Les Dietes del Pacient' : 'Les Meves Dietes'),
            backgroundColor: Colors.greenAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isDescending = !_isDescending;
                              _sortDietes();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isDescending
                                    ? 'Puntuació Descendent'
                                    : 'Puntuació Ascendent',
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentFilter = 'today';
                              _selectedDate = null;
                              _dietes = [];
                              _mostrarFavorits = false; // Reiniciar el filtro
                            });
                            _fetchDietes();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          ),
                          child: const Text(
                            'Restablir filtres',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showDatePicker,
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          label: const Text(
                            'Selecciona una data',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Favorits',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: _mostrarFavorits,
                                    activeColor: Colors.amber,
                                    onChanged: (value) {
                                      setState(() {
                                        _mostrarFavorits = value;
                                      });
                                      _fetchDietes();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                Text(
                  _currentFilter == 'today'
                      ? 'Dietes d\'Avui'
                      : (_currentFilter == 'calendar' && _selectedDate != null
                      ? 'Dieta del: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Totes les Meves Dietes'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _dietes.isEmpty
                      ? Center(
                    child: Text(
                      _currentFilter == 'today'
                          ? 'No tens cap dieta registrada per avui'
                          : 'No tens cap dieta registrada',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dietes.length,
                    itemBuilder: (context, index) {
                      final dieta = _dietes[index];
                      final nombre = dieta['nombre'] ?? 'Sense nom';
                      final fechaCreacion =
                      (dieta['fechaCreacion'] as Timestamp).toDate();
                      final puntuacionTotal = dieta['puntuacionTotal'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        child: ListTile(
                          title: Text(nombre),
                          subtitle: Text(
                            'Puntuació Total: $puntuacionTotal\nCreada el: ${DateFormat('dd/MM/yyyy').format(fechaCreacion)}',
                          ),
                          trailing: Icon(
                            puntuacionTotal <= 3
                                ? Icons.check_circle
                                : puntuacionTotal <= 6
                                ? Icons.info
                                : Icons.warning,
                            color: puntuacionTotal <= 2
                                ? Colors.green
                                : puntuacionTotal <= 6
                                ? Colors.orange
                                : Colors.red,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => laMevaDietaDetall(
                                  userId: widget.userId,
                                  nombre: nombre,
                                  fechaCreacion: fechaCreacion,
                                  puntuacionTotal: puntuacionTotal,
                                  esFavorito: dieta['favorito'] ?? false,
                                  alimentos: dieta['alimentos'] ?? [],
                                  dietaId: dieta.id,
                                  onDelete: (String dietaId) async {
                                    await _deleteDiet(dietaId, index);
                                  },
                                ),
                              ),

                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
            child: ElevatedButton(
              onPressed: _toggleDietas,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                _currentFilter == 'today'
                    ? 'Veure Totes les Dietes'
                    : 'Veure Dietes d\'Avui',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
