import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class DadesFamiliars extends StatefulWidget {
  final String userId;
  final bool isFamiliar;
  final String? relatedPatientId;

  const DadesFamiliars({
    Key? key,
    required this.userId,
    this.isFamiliar = false,
    this.relatedPatientId,
  }) : super(key: key);

  @override
  _DadesFamiliarsState createState() => _DadesFamiliarsState();
}

class _DadesFamiliarsState extends State<DadesFamiliars> {
  final TextEditingController _dataNaixementController =
      TextEditingController();
  final TextEditingController _dniPacientController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _adrecaController = TextEditingController();
  final TextEditingController _poblacioController = TextEditingController();
  final TextEditingController _codiPostalController = TextEditingController();
  final TextEditingController _dniFamiliarController = TextEditingController();

  String? _selectedFamiliar;
  DateTime? _selectedDate;
  bool _dniExiste = false;
  bool _isSubmitting = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _dataNaixementController.dispose();
    _dniPacientController.dispose();
    _telefonController.dispose();
    _adrecaController.dispose();
    _poblacioController.dispose();
    _codiPostalController.dispose();
    _dniFamiliarController.dispose();
    super.dispose();
  }

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
        _dataNaixementController.text =
            '${picked.day}-${picked.month}-${picked.year}';
      });
    }
  }

  bool validarDni(String dni) {
    final value = dni.trim().toUpperCase();
    if (value.length != 9) return false;
    final numeros = value.substring(0, 8);
    if (!RegExp(r'^\d{8}$').hasMatch(numeros)) return false;
    final letra = value.substring(8);
    return RegExp(r'^[A-Z]$').hasMatch(letra);
  }

  Future<String?> obtenerPatientIdPorDNI(String dni) async {
    final dniValue = dni.trim().toUpperCase();
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Usuarios').get();

    for (final userDoc in querySnapshot.docs) {
      final personalDataSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userDoc.id)
          .collection('dadesPersonals')
          .doc('dades')
          .get();

      if (personalDataSnapshot.exists) {
        final data = personalDataSnapshot.data() as Map<String, dynamic>;
        if ((data['Dni'] ?? '').toString().toUpperCase() == dniValue) {
          return userDoc.id;
        }
      }
    }
    return null;
  }

  Future<void> validarDniEnTiempoReal(String dni) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final patientId = await obtenerPatientIdPorDNI(dni);
      if (!mounted) return;
      if (dni == _dniPacientController.text) {
        setState(() {
          _dniExiste = patientId != null;
        });
      }
    });
  }

  Future<void> guardarDatosFamiliares(
    BuildContext context,
    String userId,
    String dataNaixement,
    String dniPacient,
    String familiar,
    String telefon,
    String adreca,
    String poblacio,
    String codiPostal,
    String dniFamiliar,
  ) async {
    if (_isSubmitting) return;

    final dataNaixementValue = dataNaixement.trim();
    final dniPacientValue = dniPacient.trim().toUpperCase();
    final familiarValue = familiar.trim();
    final telefonValue = telefon.trim();
    final adrecaValue = adreca.trim();
    final poblacioValue = poblacio.trim();
    final codiPostalValue = codiPostal.trim();
    final dniFamiliarValue = dniFamiliar.trim().toUpperCase();

    if (dataNaixementValue.isEmpty ||
        dniPacientValue.isEmpty ||
        familiarValue.isEmpty ||
        telefonValue.isEmpty ||
        adrecaValue.isEmpty ||
        poblacioValue.isEmpty ||
        codiPostalValue.isEmpty ||
        dniFamiliarValue.isEmpty) {
      _mostrarAlerta(context, 'Campos obligatorios',
          'Por favor, complete todos los campos.');
      return;
    }

    if (telefonValue.length != 9) {
      _mostrarAlerta(context, 'Telefono invalido',
          'Por favor, introduzca un numero de telefono valido de 9 digitos.');
      return;
    }

    if (!validarDni(dniPacientValue) || !validarDni(dniFamiliarValue)) {
      _mostrarAlerta(
          context, 'DNI invalido', 'Por favor, introduzca un DNI valido.');
      return;
    }

    final patientId = await obtenerPatientIdPorDNI(dniPacientValue);
    if (patientId == null) {
      _mostrarAlerta(context, 'DNI no encontrado',
          'No se encontro ningun paciente con el DNI ingresado.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userRef =
          FirebaseFirestore.instance.collection('Usuarios').doc(userId);
      final batch = FirebaseFirestore.instance.batch();

      batch.set(
        userRef.collection('dadesFamiliars').doc('dades'),
        {
          'dataNaixement': dataNaixementValue,
          'DniPacient': dniPacientValue,
          'familiar': familiarValue,
          'telefon': telefonValue,
          'adreca': adrecaValue,
          'poblacio': poblacioValue,
          'codiPostal': codiPostalValue,
          'DniFamiliar': dniFamiliarValue,
        },
      );

      batch.set(
        userRef.collection('relacionFamiliarPaciente').doc('relacio'),
        {
          'DniPaciente': dniPacientValue,
          'DniFamiliar': dniFamiliarValue,
          'familiar': familiarValue,
        },
      );

      await batch.commit();

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Benvingut👋'),
            content: const Text('Dades guardades correctament.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPrincipal(
            userId: userId,
            isFamiliar: true,
            relatedPatientId: patientId,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _mostrarAlerta(context, 'Error',
          'No se pudieron guardar los datos. Revisa los campos e intentalo de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _mostrarAlerta(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 196, 249),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Dades Familiars',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
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
                            decoration: const InputDecoration(
                              hintText: 'Data de naixement',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _dniPacientController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Dni pacient',
                            ),
                            onChanged: validarDniEnTiempoReal,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dniExiste
                                ? 'El DNI esta registrado en el sistema'
                                : 'El DNI no esta registrado',
                            style: TextStyle(
                              color: _dniExiste ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Familiar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 70,
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          items: [
                            'Pare',
                            'Mare',
                            'Germa/na',
                            'Parella',
                            'Altres'
                          ]
                              .map((String value) => DropdownMenuItem<String>(
                                  value: value, child: Text(value)))
                              .toList(),
                          value: _selectedFamiliar,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedFamiliar = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Selecciona una opcion',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _telefonController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        decoration: const InputDecoration(hintText: 'Telefon'),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _adrecaController,
                        decoration: const InputDecoration(hintText: 'Adreca'),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _poblacioController,
                        decoration: const InputDecoration(hintText: 'Poblacio'),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codiPostalController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(hintText: 'Codi postal'),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _dniFamiliarController,
                        textCapitalization: TextCapitalization.characters,
                        decoration:
                            const InputDecoration(hintText: 'Dni Familiar'),
                      ),
                    ],
                  ),
                ),
                BtnGeneral(
                  buttonText: _isSubmitting ? 'Guardant...' : 'Enviar',
                  onTap: () {
                    guardarDatosFamiliares(
                      context,
                      widget.userId,
                      _dataNaixementController.text,
                      _dniPacientController.text,
                      _selectedFamiliar ?? '',
                      _telefonController.text,
                      _adrecaController.text,
                      _poblacioController.text,
                      _codiPostalController.text,
                      _dniFamiliarController.text,
                    );
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
