import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/menu_principal.dart';
class DadesFamiliars extends StatefulWidget {
  final String userId;

  const DadesFamiliars({Key? key, required this.userId}) : super(key: key);

  @override
  _DadesFamiliarsState createState() => _DadesFamiliarsState();
}

class _DadesFamiliarsState extends State<DadesFamiliars> {
  // Controladors per a cada camp de text
  TextEditingController _dataNaixementController = TextEditingController();
  TextEditingController _DniPacientContoller = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _adrecaController = TextEditingController();
  TextEditingController _poblacioController = TextEditingController();
  TextEditingController _codiPostalController = TextEditingController();
  TextEditingController _dniFamiliarController = TextEditingController();
  String? _selectedFamiliar;
  DateTime? _selectedDate;
  bool _dniExiste = false;
  Timer? _debounce;

  // Funció per imprimir tots els DNI dels pacients a la consola
  Future<void> imprimirDnisPacientes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in querySnapshot.docs) {
      var personalDataSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userDoc.id)
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        var data = personalDataSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('Dni')) {
          print('DNI del pacient ${userDoc.id}: ${data['Dni']}');
        }
      }
    }
  }

  // Funció per seleccionar la data de naixement
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        String formattedDate = "${picked.day}-${picked.month}-${picked.year}";
        _dataNaixementController.text = formattedDate;
      });
    }
  }

  // Mètode per validar que el DNI és vàlid
  bool validarDni(String dni) {
    if (dni.length != 9) return false; // El DNI ha de tenir 9 caràcters
    String numerosDni = dni.substring(0, 8);
    if (!numerosDni.runes.every((char) => char >= 48 && char <= 57))
      return false; // Comprova que els 8 primers caràcters siguin números
    String letraDni = dni.substring(8);
    return letraDni.runes.every((char) => char >= 65 && char <= 90); // Comprova que l'últim caràcter sigui una lletra
  }

  // Verificar si existeix un pacient amb el DNI
  Future<bool> existePacienteConDNI(String Dni) async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Usuarios').get();

    for (var userDoc in querySnapshot.docs) {
      var personalDataSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userDoc.id)
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        var data = personalDataSnapshot.data() as Map<String, dynamic>;
        if (data['Dni'] == Dni) {
          return true; // Pacient trobat
        }
      }
    }
    return false; // No s'ha trobat el pacient amb el DNI
  }

  // Validació del DNI en temps real (després d'un retard per evitar consultes excessives)
  Future<void> validarDniEnTiempoReal(String dni) async {
    _debounce?.cancel(); // Cancela la sol·licitud anterior si l'usuari segueix escrivint

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      bool existe = await existePacienteConDNI(dni);
      if (dni == _DniPacientContoller.text) {
        setState(() {
          _dniExiste = existe;
        });
      }
    });
  }

  // Funció per guardar les dades familiars
  Future<void> guardarDatosFamiliares(
      BuildContext context,
      String userId,
      String dataNaixement,
      String DniPacient,
      String familiar,
      String telefon,
      String adreca,
      String poblacio,
      String codiPostal,
      String DniFamiliar,
      ) async {
    // Comprova si algun camp obligatori està buit
    if (dataNaixement.isEmpty ||
        DniPacient.isEmpty ||
        _selectedFamiliar == null ||
        telefon.isEmpty ||
        adreca.isEmpty ||
        poblacio.isEmpty ||
        codiPostal.isEmpty ||
        DniFamiliar.isEmpty) {
      _mostrarAlerta(context, "Campos obligatorios",
          "Por favor, complete todos los campos.");
    } else if (telefon.length != 9) {
      // Comprova si el número de telèfon és vàlid
      _mostrarAlerta(context, "Teléfono inválido",
          "Por favor, introduzca un número de teléfono válido de 9 dígitos.");
    } else if (!validarDni(DniPacient) || !validarDni(DniFamiliar)) {
      // Comprova si els DNI són vàlids
      _mostrarAlerta(
          context, "DNI inválido", "Por favor, introduzca un DNI válido.");
    } else {
      bool pacienteExiste = await existePacienteConDNI(DniPacient);
      if (!pacienteExiste) {
        // Si el pacient no existeix, mostrar alerta
        _mostrarAlerta(context, "DNI no encontrado",
            "No se encontró ningún paciente con el DNI ingresado.");
      } else {
        // Si el pacient existeix, mostrar alerta confirmant-ho
        _mostrarAlerta(context, "DNI ENCONTRADO",
            "se encontró paciente con el DNI ingresado.");
        try {
          // Guardar les dades familiars a Firestore
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(userId)
              .collection('dadesFamiliars')
              .doc('dades')
              .set({
            'dataNaixement': dataNaixement,
            'DniPacient': DniPacient,
            'familiar': familiar,
            'telefon': telefon,
            'adreca': adreca,
            'poblacio': poblacio,
            'codiPostal': codiPostal,
            'DniFamiliar': DniFamiliar,
          });

          print("dades familiars guardades correctament.");

          // Crear la relació entre el pacient i el familiar
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(userId)
              .collection('relacionFamiliarPaciente')
              .add({
            'DniPaciente': DniPacient,
            'DniFamiliar': DniFamiliar,
            'familiar': familiar,
          });

          print("Relació pacient-familiar guardada correctament.");

          // Redirigir a la pantalla següent
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuPrincipal(userId: userId)),
          );
        } catch (e) {
          print("Error al guardar los datos: $e");
        }
      }
    }
  }

  // Funció per mostrar alertes d'error o èxit
  void _mostrarAlerta(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    imprimirDnisPacientes(); // Crida per imprimir els DNIs dels pacients
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 161, 196, 249),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  "Dades Familiars",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dataNaixementController,
                            decoration: InputDecoration(
                              hintText: 'Data de naixement',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _DniPacientContoller,
                              decoration: const InputDecoration(
                                hintText: 'Dni pacient',
                              ),
                              onChanged: (value) {
                                validarDniEnTiempoReal(value);
                              },
                            ),
                            const SizedBox(
                                height:
                                    8), // Espaciado entre el campo y el mensaje
                            Text(
                              _dniExiste
                                  ? '✅ El DNI està registrat en el sistema'
                                  : '❌ El DNI no està registrat',
                              style: TextStyle(
                                color: _dniExiste ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      const Text(
                        "Familiar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: [
                            'Pare',
                            'Mare',
                            'Germa/na',
                            'Parella',
                            'Altres'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          value: _selectedFamiliar,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedFamiliar = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opción',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _telefonController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        decoration: InputDecoration(hintText: 'Telèfon'),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _adrecaController,
                        decoration: InputDecoration(hintText: 'Adreça'),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _poblacioController,
                        decoration: InputDecoration(hintText: 'Població'),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _codiPostalController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(hintText: 'Codi postal'),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _dniFamiliarController,
                        decoration: InputDecoration(hintText: 'Dni Familiar'),
                      ),
                    ],
                  ),
                ),
                BtnGeneral(
                  buttonText: "Enviar",
                  onTap: () {
                    String dataNaixement = _dataNaixementController.text;
                    String DniPacient = _DniPacientContoller.text;
                    String telefon = _telefonController.text;
                    String adreca = _adrecaController.text;
                    String poblacio = _poblacioController.text;
                    String codiPostal = _codiPostalController.text;
                    String DniFamiliar = _dniFamiliarController.text;

                    guardarDatosFamiliares(
                        context,
                        widget.userId,
                        dataNaixement,
                        DniPacient,
                        _selectedFamiliar ?? '',
                        telefon,
                        adreca,
                        poblacio,
                        codiPostal,
                        DniFamiliar);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
