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
  late Future<DocumentSnapshot> _userData;
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> _isEditing =
      {}; // Para manejar el modo de edición de cada campo

  // Variable que mantendrá el valor seleccionado en el Dropdown
  Map<String, String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _userData = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('dadesMediques')
        .doc('datos')
        .get();
  }

  // Función para guardar cambios
  Future<void> _saveChanges(String field) async {
    try {
      // Si el campo es 'hipertens', usamos el valor del _selectedValues
      if (field == 'hipertens' ||
          field == 'diabetic' ||
          field == 'pacientExpert' ||
          field == 'activitatFisica' ||
          field == 'estadio') {
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('dadesMediques')
            .doc('datos')
            .update({field: _selectedValues[field]});
      } else {
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('dadesMediques')
            .doc('datos')
            .update({field: _controllers[field]?.text});
      }

      // Refrescar la vista con setState
      setState(() {
        _isEditing[field] = false; // Desactiva el modo de edición
        _userData = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('dadesMediques')
            .doc('datos')
            .get(); // Recarga los datos
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MenuPrincipal(userId: widget.userId)),
              (route) => false,
            );
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No s''han trobat dades.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          // Inicializar los valores de los desplegables
          if (!_selectedValues.containsKey('hipertens') &&
              data['hipertens'] != null) {
            _selectedValues['hipertens'] = data['hipertens'] ?? 'No';
          }
          if (!_selectedValues.containsKey('diabetic') &&
              data['diabetic'] != null) {
            _selectedValues['diabetic'] = data['diabetic'] ?? 'No';
          }
          if (!_selectedValues.containsKey('pacientExpert') &&
              data['pacientExpert'] != null) {
            _selectedValues['pacientExpert'] = data['pacientExpert'] ?? 'No';
          }
          if (!_selectedValues.containsKey('activitatFisica') &&
              data['activitatFisica'] != null) {
            _selectedValues['activitatFisica'] =
                data['activitatFisica'] ?? 'No';
          }
          if (!_selectedValues.containsKey('estadio') &&
              data['estadio'] != null) {
            _selectedValues['estadio'] =
                data['estadio'] ?? '1'; // Default value '1' en caso de null
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Dades Mèdiques",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoTile(
                    'Alçada:', data['alcada'] ?? 'No disponible', 'alcada'),
                _buildInfoTile('Pes:', data['pes'] ?? 'No disponible', 'pes'),
                _buildInfoTile(
                    'Estat:', data['estat'] ?? 'No disponible', 'estat'),
                _buildInfoTile('Diabètic:', data['diabetic'] ?? 'No disponible',
                    'diabetic'),
                _buildInfoTile(
                    'Estadio:', data['estadio'] ?? 'No disponible', 'estadio'),
                _buildInfoTile('Hipertens:',
                    data['hipertens'] ?? 'No disponible', 'hipertens'),
                _buildInfoTile('Pacient Expert:',
                    data['pacientExpert'] ?? 'No disponible', 'pacientExpert'),
                _buildInfoTile(
                    'Activitat Física:',
                    data['activitatFisica'] ?? 'No disponible',
                    'activitatFisica'),
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
    if (field == 'hipertens' ||
        field == 'diabetic' ||
        field == 'activitatFisica' ||
        field == 'pacientExpert') {
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
                    const SizedBox(height: 10),
                    _isEditing[field] == true
                        ? DropdownButton<String>(
                            value: _selectedValues[field],
                            items: <String>['Sí', 'No']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedValues[field] =
                                    newValue ?? 'No'; // Actualizar el valor
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
              IconButton(
                icon: Icon(
                  _isEditing[field] == true ? Icons.save : Icons.edit,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  if (_isEditing[field] == true) {
                    _saveChanges(field); // Llamamos a _saveChanges al guardar
                  } else {
                    setState(() {
                      _isEditing[field] = true; // Activamos el modo de edición
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else if (field == 'estadio') {
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
                    const SizedBox(height: 10),
                    _isEditing[field] == true
                        ? DropdownButton<String>(
                            value: _selectedValues[
                                field], // Valor desde el estado inicial
                            items: List.generate(25, (index) {
                              int value =
                                  index + 1; // Esto genera números de 1 a 25
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()),
                              );
                            }),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedValues[field] = newValue ??
                                    '1'; // Valor por defecto '1' si es nulo
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
              IconButton(
                icon: Icon(
                  _isEditing[field] == true ? Icons.save : Icons.edit,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  if (_isEditing[field] == true) {
                    _saveChanges(field);
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
    } else {
      // Si es un campo de texto
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
                              hintText: 'Introduce un valor',
                            ),
                            onSubmitted: (_) => _saveChanges(field),
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
              IconButton(
                icon: Icon(
                  _isEditing[field] == true ? Icons.save : Icons.edit,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  if (_isEditing[field] == true) {
                    _saveChanges(field); // Guardar cambios si está editando
                  } else {
                    setState(() {
                      _isEditing[field] = true; // Entrar en modo de edición
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
}
