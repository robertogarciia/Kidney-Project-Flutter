import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class DadesFamiliars extends StatefulWidget {
  final String userId;

  const DadesFamiliars({Key? key, required this.userId}) : super(key: key);

  @override
  _DadesFamiliarsState createState() => _DadesFamiliarsState();
}

class _DadesFamiliarsState extends State<DadesFamiliars> {
  TextEditingController _dataNaixementController = TextEditingController();
  TextEditingController _DniPacientContoller = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _adrecaController = TextEditingController();
  TextEditingController _poblacioController = TextEditingController();
  TextEditingController _codiPostalController = TextEditingController();
  String? _selectedFamiliar;
  DateTime? _selectedDate;

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

  bool validarDni(String dni) {
    // Comprobamos la longitud
    if (dni.length != 9) return false;
  
    // Comprobamos que los primeros 8 caracteres sean números
    String numerosDni = dni.substring(0, 8);
    if (!numerosDni.runes.every((char) => char >= 48 && char <= 57)) return false;
  
    // Comprobamos que el último caracter sea una letra
    String letraDni = dni.substring(8);
    return letraDni.runes.every((char) => char >= 65 && char <= 90);
  }

  Future<void> guardarDatosFamiliares(
      BuildContext context,
      String userId,
      String dataNaixement,
      String DniPacient,
      String familiar,
      String telefon,
      String adreca,
      String poblacio,
      String codiPostal) async {
    if (dataNaixement.isEmpty ||
        DniPacient.isEmpty ||
        _selectedFamiliar == null ||
        telefon.isEmpty ||
        adreca.isEmpty ||
        poblacio.isEmpty ||
        codiPostal.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Campos obligatorios"),
            content: Text("Por favor, complete todos los campos."),
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
    } else if (telefon.length != 9) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Teléfono inválido"),
            content: Text("Por favor, introduzca un número de teléfono válido de 9 dígitos."),
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
    } else if (!validarDni(DniPacient)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("DNI inválido"),
            content: Text("Por favor, introduzca un DNI válido."),
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
    } else {
      // Guardar los datos en Firestore
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('dadesFamiliars')
          .add({
        'dataNaixement': dataNaixement,
        'DniPacient': DniPacient,
        'familiar': familiar,
        'telefon': telefon,
        'adreca': adreca,
        'poblacio': poblacio,
        'codiPostal': codiPostal,
      });

      // Redirigir a la página del menú principal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPrincipal(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xA6403DF3),
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
                      TextField(
                        controller: _DniPacientContoller,
                        decoration: InputDecoration(hintText: 'Dni pacient'),
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
                        height: 50,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Pare', 'Mare', 'Germa/na', 'Parella', 'Altres']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
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

                    guardarDatosFamiliares(
                        context,
                        widget.userId,
                        dataNaixement,
                        DniPacient,
                        _selectedFamiliar ?? '',
                        telefon,
                        adreca,
                        poblacio,
                        codiPostal);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
