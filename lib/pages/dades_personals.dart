import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/dades_mediques.dart';
import 'package:kidneyproject/pages/dades_personals2.dart';

class DadesPersonals extends StatefulWidget {
  final String userId;

  const DadesPersonals({Key? key, required this.userId}) : super(key: key);

  @override
  _DadesPersonalsState createState() => _DadesPersonalsState();
}

class _DadesPersonalsState extends State<DadesPersonals> {
  TextEditingController _sexeController = TextEditingController();
  TextEditingController _dataNaixementController = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _adrecaController = TextEditingController();
  TextEditingController _poblacioController = TextEditingController();
  TextEditingController _codiPostalController = TextEditingController();
  String? _selectedSexe;

  Future<void> guardarDatosPersonales(BuildContext context, String userId, String dataNaixement, String sexe, String telefon, String adreca, String poblacio, String codiPostal) async {
    // Guardar los datos personales en la colección 'dadesPersonals' dentro del documento del usuario
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('dadesPersonals')
        .doc('dades')
        .set({
      'dataNaixement': dataNaixement,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),

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
                  color: Color(0xA6403DF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _dataNaixementController,
                      decoration: InputDecoration(hintText: 'Data de naixement'),
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
                      decoration: InputDecoration(hintText: 'Telefon'),
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
                      decoration: InputDecoration(hintText: 'Codi postal'),
                    ),
                  ],
                ),
              ),
              BtnGeneral(
                buttonText: "Enviar",
                onTap: () {
                  String dataNaixement = _dataNaixementController.text;
                  String telefon = _telefonController.text;
                  String adreca = _adrecaController.text;
                  String poblacio = _poblacioController.text;
                  String codiPostal = _codiPostalController.text;

                  guardarDatosPersonales(context, widget.userId, dataNaixement, _selectedSexe ?? '', telefon, adreca, poblacio, codiPostal);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
