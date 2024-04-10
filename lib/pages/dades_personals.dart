import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para InputFormatters
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:kidneyproject/pages/dades_mediques.dart';
import 'package:kidneyproject/components/btn_general.dart';

class DadesPersonals extends StatefulWidget {
  final String userId;

  const DadesPersonals({Key? key, required this.userId}) : super(key: key);

  @override
  _DadesPersonalsState createState() => _DadesPersonalsState();
}

class _DadesPersonalsState extends State<DadesPersonals> {
  TextEditingController _dataNaixementController = TextEditingController();
  TextEditingController _DniContoller = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _adrecaController = TextEditingController();
  TextEditingController _poblacioController = TextEditingController();
  TextEditingController _codiPostalController = TextEditingController();
  String? _selectedSexe;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
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

  Future<void> guardarDatosPersonales(BuildContext context, String userId,
      String dataNaixement,String Dni, String sexe, String telefon, String adreca,
      String poblacio, String codiPostal) async {
    if (
      dataNaixement.isEmpty ||
      Dni.isEmpty ||
        _selectedSexe == null ||
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
    } else if (!validarDni(Dni)) {
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
      // Guardar los datos personales en la colección 'dadesPersonals' dentro del documento del usuario
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('dadesPersonals')
          .doc('dades')
          .set({
        'dataNaixement': dataNaixement,
        'Dni': Dni,
        'sexe': sexe,
        'telefon': telefon,
        'adreca': adreca,
        'poblacio': poblacio,
        'codiPostal': codiPostal,
      });

      // Después de guardar los datos personales, redirigir a la página deseada
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Formulario3(userId: userId)),
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
                  "Dades Personals",
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
                        controller: _DniContoller,
                        decoration: InputDecoration(hintText: 'Dni'),
                      ),
                      SizedBox(height: 20),
                      const Text(
                        "Sexe",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 300,
                        child: DropdownButtonFormField(
                          items: ['Mujer', 'Hombre', 'Otros'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          value: _selectedSexe,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedSexe = value;
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
                        keyboardType: TextInputType.phone, // Teclado numérico
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Solo permite números
                          LengthLimitingTextInputFormatter(9), // Limita a 9 dígitos
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
                          FilteringTextInputFormatter.digitsOnly, // Solo permite números
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
                    String Dni = _DniContoller.text;
                    String telefon = _telefonController.text;
                    String adreca = _adrecaController.text;
                    String poblacio = _poblacioController.text;
                    String codiPostal = _codiPostalController.text;

                    guardarDatosPersonales(context, widget.userId, dataNaixement,Dni, _selectedSexe ?? '', telefon, adreca, poblacio, codiPostal);
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
