import 'package:flutter/material.dart';
import 'package:kidneyproject/components/button.dart';
import 'package:kidneyproject/components/btn_registrar.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/services/firabase_service.dart';

class SignUpTypePage extends StatefulWidget {
  SignUpTypePage({Key? key}) : super(key: key);

  @override
  _SignUpTypePageState createState() => _SignUpTypePageState();
}

class _SignUpTypePageState extends State<SignUpTypePage> {
  TextEditingController _nameController = TextEditingController(text: "");
  TextEditingController _emailController = TextEditingController(text: "");
  TextEditingController _contrasenyaController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>(); 
  bool isEmailValid = false; //  verificar si es valid del correu

  bool hasUpperCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;

  bool showPasswordRestrictions = false;

  void registerUser() async {
    // Verifica si el nom esta buit
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si us plau, ingressa el teu nom.'),
        ),
      );
      return;
    }

    // Verifica si el correu electrònic está buit
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si us plau, ingressa el teu correu electrònic.'),
        ),
      );
      return;
    }

    // Correcció en la expressió per validar el format del correu electrònico
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si us plau, ingressa un correu electrònic vàlid.'),
        ),
      );
      return;
    }

    // Verificar si la contrasenya està buit
    if (_contrasenyaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si us plau, ingressa la teva contrasenya.'),
        ),
      );
      return;
    }

    // Verifica si es cumpleixen els requisits de la contrasenya
    if (!hasUpperCase || !hasNumber || !hasSpecialChar || !hasMinLength) {
      // Mostra missatge de error y no continuar amb el registre
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si us plau, assegura\'t de cumplir tots els requisits de la contrasenya.'),
        ),
      );
      return;
    }

    // Verifica si el formulari és vàlido i el correu electrònico és vàlid
    if ((_formKey.currentState?.validate() ?? false) && isEmailValid) {
      // Si el formulari és vàlid i el correu és vàlid, fer registre
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _contrasenyaController.text;

      try {
        // Llama a la funció de registre en el servei de Firebase
        await addUsuario(name, email, password);
        navigateToSignInPage(context);
      } catch (e) {
        print('Error durant el registre: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error durant el registre. Si us plau, torna a intentar-ho de nou.'),
          ),
        );
      }
    }
  }

  void navigateToSignInPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),

                // Texto "Registra't"
                const Text(
                  'Registra\'t',

              ),

              //logo
              Image.asset(
                'lib/images/logoKNP_WT.png',
                height: 300,
              ),

              TextFieldWidget(
                controller: nameController,
                hintText: 'Nom',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              TextFieldWidget(
                controller: usernameController,
                hintText: 'Correu Electronic',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              TextFieldWidget(
                controller: passwordController,
                hintText: 'Constrasenya',
                obscureText: true,
              ),

              const SizedBox(height: 15),

              //button inicia sessio
              BtnRegistrar(
                onTap: signUserIn,
              ),

              const SizedBox(height: 15),

              //Oblidat Contrasenya
              GestureDetector(
                onTap: () {
                  navigateToSignInPage(context);
                },
                child: Text(
                  'Ja tens compte? Inicia Sessió',

                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Logo
                Image.asset(
                  'lib/images/logoKNP_NT.png',
                  height: 200,
                ),

                // Camp de nom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Si us plau, ingressa el teu nom';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Camp de correu electrònico
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Correu Electrònic',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Si us plau, ingressa un correu electrònic';
                      }

                      // required contrasenya
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$').hasMatch(value)) {
                        setState(() {
                          isEmailValid = false; 
                        });
                        return 'Si us plau, ingressa un correu electrònic vàlid';
                      }

                      setState(() {
                        isEmailValid = true; // correu valid
                      });

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Camp de contrasenya
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PasswordField(
                    controller: _contrasenyaController,
                    onChanged: (value) {
                      setState(() {
                        hasUpperCase = value.contains(RegExp(r'[A-Z]'));
                        hasNumber = value.contains(RegExp(r'[0-9]'));
                        hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        hasMinLength = value.length >= 6;
                        showPasswordRestrictions = true;
                      });
                    },
                    onTap: () {
                      setState(() {
                        showPasswordRestrictions = true;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Mostrar restriccions
                if (showPasswordRestrictions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_contrasenyaController.text.isEmpty)
                          Text(
                            'Si us plau, ingressa una contrasenya',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        Text(
                          'Al menys una mayúscula: ${hasUpperCase ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasUpperCase ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Al menys un número: ${hasNumber ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasNumber ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Al menys un caràcter especial: ${hasSpecialChar ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasSpecialChar ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          'Longitut mínima de 6 caràcteres: ${hasMinLength ? '✔' : '❌'}',
                          style: TextStyle(
                            color: hasMinLength ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 15),

                // Buto de registrar
                btn_registrar(
                  onTap: registerUser,
                ),

                const SizedBox(height: 15),

                // Olvidar Contrasenya
                GestureDetector(
                  onTap: () {
                    navigateToSignInPage(context);
                  },
                  child: Text(
                    'Ja tens compte? Inicia Sessió',
                    style: TextStyle(
                      color: Colors.grey[800],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const PasswordField({
    Key? key,
    required this.controller,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Contrasenya',
        border: OutlineInputBorder(),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      obscureText: !_showPassword,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Si us plau, ingressa una contrasenya';
        }
        return null;
      },
    );
  }
}
