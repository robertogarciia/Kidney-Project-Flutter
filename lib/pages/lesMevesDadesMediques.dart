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
// variables
class _LesMevesDadesMediquesState extends State<LesMevesDadesMediques> {
  // Variables per carregar i controlar les dades de l'usuari
  late Future<List<DocumentSnapshot>> _userData;
  Map<String, TextEditingController> _controllers = {};  // Controladors per als camps d'entrada
  Map<String, bool> _isEditing = {};  // Estat per saber si un camp és editable
  Map<String, String> _selectedValues = {};  // Valors seleccionats per als camps desplegables

  @override
  void initState() {
    super.initState();
    // Carregar les dades de l'usuari quan s'inicia l'estat
    _userData = _loadUserData();
  }
  String _formatValue(String field, String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (field == 'pes') {
      return '$cleaned kg';
    } else if (field == 'alcada') {
      return '$cleaned m';
    }
    return cleaned;
  }

  // Funció per carregar les dades de l'usuari des de Firestore
  Future<List<DocumentSnapshot>> _loadUserData() async {
    print("Cargando datos del usuario: ${widget.userId}");

    // Obtenim el document de tipus de l'usuari (pacient o familiar)
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

    // Si és un familiar, carregar les dades del pacient relacionat
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

      // Carregar les dades del pacient relacionat
      return await _loadPatientData(dniPaciente);

    } else if (userData['tipo'] == 'Pacient') {
      print("Cargando datos médicos para el paciente...");

      // Carregar les dades mèdiques i generals per al pacient
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

  // Funció per carregar les dades del pacient relacionat a partir del DNI
  Future<List<DocumentSnapshot>> _loadPatientData(String dniPaciente) async {
    print("Buscando datos del paciente con DNI: $dniPaciente");

    final usersSnapshot = await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in usersSnapshot.docs) {
      // Buscar primer a 'dadesPersonals'
      final personalDataSnapshot = await userDoc.reference
          .collection('dadesPersonals') // Canviem a 'dadesPersonals'
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final personalData = personalDataSnapshot.data();
        print("Datos personales encontrados en usuario ${userDoc.id}");

        if (personalData?['Dni'] == dniPaciente) {
          print("Paciente encontrado con DNI en 'dadesPersonals'. Cargando datos médicos...");

          // Ara carreguem 'dadesMediques'
          final medicalDataSnapshot = await userDoc.reference
              .collection('dadesMediques')
              .doc('datos')
              .get();

          if (!medicalDataSnapshot.exists) {
            print("Error: No se encontraron dadesMediques para el paciente con DNI: $dniPaciente");
            return [];
          }

          // Carregar les dades generals del pacient
          final generalDataSnapshot = await userDoc.reference.get();
          return [medicalDataSnapshot, generalDataSnapshot];
        }
      }
    }

    print("Error: No se encontró un paciente con el DNI: $dniPaciente en 'dadesPersonals'");
    return [];
  }

  // Funció per desar els canvis realitzats en els camps d'entrada
  Future<void> _saveChanges(String field, String value) async {
    try {
      // Guardar el valor en Firestore
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('dadesMediques')
          .doc('datos')
          .update({field: value});

      // Actualizar el estado de la UI
      setState(() {
        _isEditing[field] = false;
        // Recargar los datos después de la actualización
        _userData = _loadUserData(); // Asegúrate de que esta función recarga los datos correctamente
      });

      // Si el campo es relevante para recalcular el tipusC, llamamos al método de recalculación
      if (['pes', 'alcada', 'estat', 'activitatFisica', 'diabetic'].contains(field)) {
        await _recalculaITipusC();
      }

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dades actualitzades correctament.')),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualitzar les dades.')),
      );
    }
  }




  // Funció per obtenir el controlador per un camp concret
  TextEditingController _getController(String field, [String? initialValue]) {
    if (!_controllers.containsKey(field)) {
      // Solo el número, sin sufijos
      final cleaned = initialValue?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
      _controllers[field] = TextEditingController(text: cleaned);
    }
    return _controllers[field]!;
  }


  Future<void> _recalculaITipusC() async {
    final docRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('dadesMediques')
        .doc('datos');

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        print('[DEBUG] El document no existeix');
        return;
      }

      final data = snapshot.data()!;
      print('[DEBUG] Dades obtingudes: $data');

      // Traiem les unitats de pes i alçada abans de convertir-los en números
      final String pesString = data['pes']?.toString() ?? '';
      final String alcadaString = data['alcada']?.toString() ?? '';

      // Traiem les unitats "kg" de pes i "m" d'alçada
      final double? pes = double.tryParse(pesString.replaceAll(RegExp(r'[^0-9.]'), ''));
      final double? alcadaCm = double.tryParse(alcadaString.replaceAll(RegExp(r'[^0-9.]'), ''));

      final String estat = data['estat'] ?? '';
      final String activitat = data['activitatFisica'] ?? 'No';
      final String diabetic = data['diabetic'] ?? 'No';

      if (pes == null || alcadaCm == null || alcadaCm == 0) {
        print('[DEBUG] Pes o alçada no vàlids. Pes: $pes, Alcada: $alcadaCm');
        return;
      }

      final double alcada = alcadaCm / 100; // Convertim l'alçada a metres
      final double imc = pes / (alcada * alcada);
      print('[DEBUG] IMC calculat: $imc');

      String categoriaIMC;
      if (imc < 18.5) {
        categoriaIMC = 'Desnodrit';
      } else if (imc >= 25) {
        categoriaIMC = 'Obès';
      } else {
        categoriaIMC = 'Normal';
      }
      print('[DEBUG] Categoria IMC: $categoriaIMC');

      String tipusC = 'No Determinat';

      final bool actSi = activitat == 'Sí';
      final bool diaSi = diabetic == 'Sí';

      // Lògica per assignar tipusC
      if (categoriaIMC == 'Normal' && actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C1';
      else if (categoriaIMC == 'Normal' && actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C2';
      else if (categoriaIMC == 'Normal' && actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C3';
      else if (categoriaIMC == 'Normal' && actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C4';
      else if (categoriaIMC == 'Normal' && !actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C5';
      else if (categoriaIMC == 'Normal' && !actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C6';
      else if (categoriaIMC == 'Normal' && !actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C7';
      else if (categoriaIMC == 'Normal' && !actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C8';
      else if (categoriaIMC == 'Desnodrit' && actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C9';
      else if (categoriaIMC == 'Desnodrit' && actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C10';
      else if (categoriaIMC == 'Desnodrit' && actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C11';
      else if (categoriaIMC == 'Desnodrit' && actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C12';
      else if (categoriaIMC == 'Desnodrit' && !actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C13';
      else if (categoriaIMC == 'Desnodrit' && !actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C14';
      else if (categoriaIMC == 'Desnodrit' && !actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C15';
      else if (categoriaIMC == 'Desnodrit' && !actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C16';
      else if (categoriaIMC == 'Obès' && actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C17';
      else if (categoriaIMC == 'Obès' && actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C18';
      else if (categoriaIMC == 'Obès' && actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C19';
      else if (categoriaIMC == 'Obès' && actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C20';
      else if (categoriaIMC == 'Obès' && !actSi && estat == 'Pre-Diàlisi' && !diaSi) tipusC = 'C21';
      else if (categoriaIMC == 'Obès' && !actSi && estat == 'Pre-Diàlisi' && diaSi) tipusC = 'C22';
      else if (categoriaIMC == 'Obès' && !actSi && estat == 'Diàlisi' && !diaSi) tipusC = 'C23';
      else if (categoriaIMC == 'Obès' && !actSi && estat == 'Diàlisi' && diaSi) tipusC = 'C24';

      print('[DEBUG] tipusC a guardar: $tipusC');

      await docRef.update({'tipusC': tipusC});
      print('[DEBUG] tipusC actualitzat correctament a Firestore');

    } catch (e) {
      print('[ERROR] Error en recalculaITipusC: $e');
    }
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
                  "Dades Mèdiques Pacient",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                // funció per recuperar les dades
                const SizedBox(height: 20),
                _buildInfoTile('Alçada:', data['alcada'] ?? 'No disponible', 'alcada'),
                _buildInfoTile('Pes:', data['pes'] ?? 'No disponible', 'pes'),
                _buildInfoTile('Estat:', data['estat'] ?? 'No disponible', 'estat'),
                _buildInfoTile('Estadio', data['estadio']?? 'No disponible', 'estadio'),
                _buildInfoTile('Diabètic', data['diabetic']?? 'No disponible', 'diabetic'),
                _buildInfoTile('Hipertens', data['hipertens']?? 'No disponible', 'hipertens'),
                _buildInfoTile('Pacient Expert', data['pacientExpert']?? 'No disponible', 'pacientExpert'),
                _buildInfoTile('Activitat Física', data['activitatFisica']?? 'No disponible', 'activitatFisica'),

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
// funció per canviar la informació
 /* Widget _buildInfoTile(String title, String value, String field) {
    bool isSwitchField = ['activitatFisica', 'hipertens', 'pacientExpert', 'diabetic'].contains(field);
    bool isEstadioField = field == 'estadio';  // Comprobar si el campo es 'estadio'
    bool isEstatField = field == 'estat';  // Comprobar si el campo es 'estat'

    String? originalValue = _controllers[field]?.text ?? value;

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
                      ? isSwitchField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text.isNotEmpty ?? false
                        ? _controllers[field]?.text
                        : value, // Se asegura de que se use el valor actual
                    items: ['Si', 'No']
                        .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                      }
                    },
                  )
                      : isEstadioField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text.isNotEmpty ?? false
                        ? _controllers[field]?.text
                        : value, // Se asegura de que se use el valor actual
                    items: List.generate(5, (index) {
                      return DropdownMenuItem<String>(
                        value: (index + 1).toString(),
                        child: Text((index + 1).toString()),
                      );
                    }),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                      }
                    },
                  )
                      : isEstatField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text.isNotEmpty ?? false
                        ? _controllers[field]?.text
                        : value, // Se asegura de que se use el valor actual
                    items: ['Pre-Diàlisi', 'Diàlisi', 'Trasplantat']
                        .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                      }
                    },
                  )
                      : TextField(
                    controller: _getController(field),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Introdueix un valor',
                    ),
                    onChanged: (text) {
                      final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
                      String formatted = cleaned;
                      if (field == 'pes') {
                        formatted = '$cleaned kg';
                      } else if (field == 'alcada') {
                        formatted = '$cleaned m';
                      }
                      // Actualitza el text amb el format i posiciona el cursor correctament
                      _controllers[field]?.text = formatted;
                      _controllers[field]?.selection = TextSelection.fromPosition(
                        TextPosition(offset: formatted.length),
                      );
                    },
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
            // Botón de edición
            IconButton(
              icon: Icon(
                _isEditing[field] == true ? Icons.save : Icons.edit,
                color: Colors.blueAccent,
              ),
              onPressed: () async {
                if (_isEditing[field] == true) {
                  String finalValue = _controllers[field]?.text ?? originalValue;

                  // Solo se guarda si el valor ha cambiado
                  if (finalValue != originalValue) {
                    await _saveChanges(field, finalValue); // Guarda el cambio solo al presionar el botón

                    // Actualiza la UI después de guardar el cambio
                    setState(() {
                      _isEditing[field] = false;  // Desactiva el modo de edición después de guardar
                    });
                  }
                } else {
                  setState(() {
                    _isEditing[field] = true;  // Activa el modo de edición
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }*/

  Widget _buildInfoTile(String title, String value, String field) {
    bool isSwitchField = ['activitatFisica', 'hipertens', 'pacientExpert', 'diabetic'].contains(field);
    bool isEstadioField = field == 'estadio';  // Comprobar si el campo es 'estadio'
    bool isEstatField = field == 'estat';  // Comprobar si el campo es 'estat'

    String? originalValue = _controllers[field]?.text ?? value;

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
                      ? isSwitchField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text ?? value,
                    items: ['Si', 'No']
                        .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                        _saveChanges(field, newValue!);  // Guardar automáticamente
                      }
                    },
                  )
                      : isEstadioField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text ?? value,
                    items: List.generate(5, (index) {
                      return DropdownMenuItem<String>(
                        value: (index + 1).toString(),
                        child: Text((index + 1).toString()),
                      );
                    }),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                        _saveChanges(field, newValue!);  // Guardar automáticamente
                      }
                    },
                  )
                      : isEstatField
                      ? DropdownButton<String>(
                    value: _controllers[field]?.text ?? value,
                    items: ['Pre-Diàlisi', 'Diàlisi', 'Trasplantat']
                        .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != _controllers[field]?.text) {
                        setState(() {
                          _controllers[field] = TextEditingController(text: newValue);
                        });
                        _saveChanges(field, newValue!);  // Guardar automáticamente
                      }
                    },
                  )
                      : TextField(
                    controller: _getController(field),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Introdueix un valor',
                    ),
                    onChanged: (text) {
                      final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
                      String formatted = cleaned;
                      if (field == 'pes') {
                        formatted = '$cleaned kg';
                      } else if (field == 'alcada') {
                        formatted = '$cleaned m';
                      }
                      // Actualitza el text amb el format i posiciona el cursor correctament
                      setState(() {
                        _controllers[field]?.text = formatted;
                        _controllers[field]?.selection = TextSelection.fromPosition(
                          TextPosition(offset: formatted.length),
                        );
                      });
                    },
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
            // Botón de edición
            IconButton(
              icon: Icon(
                _isEditing[field] == true ? Icons.save : Icons.edit,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                if (_isEditing[field] == true) {
                  String finalValue = _controllers[field]?.text ?? originalValue;

                  // Verifica si el valor final es uno de los valores esperados
                  if (['Si', 'No'].contains(finalValue) ||
                      List.generate(5, (index) => (index + 1).toString()).contains(finalValue) ||
                      ['Pre-Diàlisi', 'Diàlisi', 'Trasplantat'].contains(finalValue)) {
                    _saveChanges(field, finalValue);  // Guardar automáticamente si el valor es válido
                  } else {
                    _saveChanges(field, originalValue);  // Si no, guardamos el valor original
                  }

                  // Después de guardar, desactivar la edición
                  setState(() {
                    _isEditing[field] = false;
                  });
                } else {
                  setState(() {
                    _isEditing[field] = true;  // Activa el modo de edición
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