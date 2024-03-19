
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/textfield.dart';
import 'package:kidneyproject/components/listfield.dart';
import 'package:kidneyproject/components/btn_general.dart';
import 'package:kidneyproject/pages/dades_personals2.dart';

class DadesPersonals extends StatefulWidget {
  DadesPersonals({Key? key}) : super(key: key);

  @override
  _DadesPersonalsState createState() => _DadesPersonalsState();
}

class _DadesPersonalsState extends State<DadesPersonals> {
  TextEditingController _nomController = TextEditingController();
  String? _selectedSexe;

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Formulario2()),
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
                    TextFieldWidget(
                      controller: _nomController,
                      hintText: 'Data de naixement',
                      obscureText: true,
                    ),

                    SizedBox( height: 20 ),

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
                      child: ListField(
                        items: ['Mujer', 'Hombre', 'Otros'],
                        value: _selectedSexe,
                        hintText: 'Selecciona una opción',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSexe = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una opción';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox( height: 20 ),

                    TextFieldWidget(
                      controller: _nomController,
                      hintText: 'Telefon',
                      obscureText: true,
                    ),
                    SizedBox( height: 20 ),

                    TextFieldWidget(
                      controller: _nomController,
                      hintText: 'Adreça',
                      obscureText: true,
                    ),

                    SizedBox( height:20 ),

                    TextFieldWidget(
                      controller: _nomController,
                      hintText: 'Població',
                      obscureText: true,
                    ),

                    SizedBox( height: 20 ),

                    TextFieldWidget(
                      controller: _nomController,
                      hintText: 'Codi postal',
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              BtnGeneral(
                buttonText: "Enviar", 
                onTap: (){
                  iniciS(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
