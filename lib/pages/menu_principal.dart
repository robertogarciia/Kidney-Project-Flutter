import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidneyproject/components/bottom_imgs.dart';
import 'package:kidneyproject/components/midle_imgs.dart';
import 'package:kidneyproject/components/top_imgs.dart';
import 'package:kidneyproject/pages/ajuda.dart';
import 'package:kidneyproject/pages/comunities_principal_page.dart';
import 'package:kidneyproject/pages/lesMevesDades.dart';
import 'package:kidneyproject/pages/logrosPage.dart';
import 'package:kidneyproject/pages/menuDietes.dart';
import 'package:kidneyproject/pages/menu_joc.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/videos_principal_page.dart';
import 'package:kidneyproject/pages/noticiesPage.dart';
import 'package:kidneyproject/pages/graficaEstatAnim.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  bool isFamiliar = false;
  bool isLoading = true;
  String relatedPatientId = '';

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  // 🔎 Verificar si es Familiar y obtener paciente
  Future<void> _checkUserType() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('tipusDeUsuario')
          .doc('tipus')
          .get();

      final userData = userDoc.data();

      if (userData != null && userData['tipo'] == 'Familiar') {
        isFamiliar = true;

        // Obtener DNI del paciente relacionado
        final relatedPatientDocs = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(widget.userId)
            .collection('relacionFamiliarPaciente')
            .get();

        if (relatedPatientDocs.docs.isNotEmpty) {
          final dniPaciente =
              relatedPatientDocs.docs.first.data()['DniPaciente'];

          if (dniPaciente != null) {
            await _getPatientIdFromDNI(dniPaciente);
          }
        }
      }
    } catch (e) {
      print("Error en _checkUserType: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // 🔎 Obtener ID del paciente usando collectionGroup (optimizado)
  // 🔎 Obtener ID del paciente usando el DNI (estructura confirmada)
  Future<void> _getPatientIdFromDNI(String dniPaciente) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('Usuarios').get();

      bool found = false;

      for (var userDoc in usersSnapshot.docs) {
        final personalDataSnapshot = await userDoc.reference
            .collection('dadesPersonals')
            .doc('dades')
            .get();

        if (personalDataSnapshot.exists) {
          final personalData = personalDataSnapshot.data();

          // Comprobamos DNI ignorando mayúsculas y espacios
          final dniStored =
              personalData?['Dni']?.toString().trim().toUpperCase();
          final dniToCheck = dniPaciente.trim().toUpperCase();

          if (dniStored == dniToCheck) {
            setState(() {
              relatedPatientId = userDoc.id;
            });
            print("Paciente encontrado: $relatedPatientId");
            found = true;
            break;
          }
        }
      }

      if (!found) {
        print("No se encontró paciente con DNI $dniPaciente");
      }
    } catch (e) {
      print("Error buscando paciente por DNI: $e");
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return await mostrarDialogoCerrarSesion(context);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),

                /// 🔹 LOGO + LOGROS
                Row(
                  children: [
                    const TopImgs(imagePath: 'assets/images/logoKNP_NT.png'),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          navigateToPage(
                              context, LogrosPage(userId: widget.userId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Menú Principal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                /// FILA 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BottomImgs(
                      imagePath: 'assets/images/mando.png',
                      onTap: () => navigateToPage(
                          context, MenuJoc(userId: widget.userId)),
                    ),
                    const SizedBox(width: 15),
                    MidleImgs(
                      imagePath: 'assets/images/vids.png',
                      onTap: () => navigateToPage(
                          context, Videos(userId: widget.userId)),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// FILA 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/ajuda.png',
                      onTap: () =>
                          navigateToPage(context, Ajuda(userId: widget.userId)),
                    ),
                    const SizedBox(width: 15),
                    MidleImgs(
                      imagePath: 'assets/images/inf.png',
                      onTap: () => navigateToPage(
                          context, noticiesPage(userId: widget.userId)),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// FILA 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/DadesPers.png',
                      width: 155,
                      height: 155,
                      onTap: () => navigateToPage(
                          context, LesMevesDades(userId: widget.userId)),
                    ),
                    const SizedBox(width: 8),
                    MidleImgs(
                      imagePath: 'assets/images/iconEstatAnim2.png',
                      width: 160,
                      height: 160,
                      onTap: () => navigateToPage(
                          context, graficaEstatAnim(userId: widget.userId)),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// FILA 4
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MidleImgs(
                      imagePath: 'assets/images/comu.png',
                      width: 155,
                      height: 155,
                      onTap: () => navigateToPage(
                          context, Comunities(userId: widget.userId)),
                    ),
                    const SizedBox(width: 8),
                    MidleImgs(
                      imagePath: 'assets/images/imatgeDietes.png',
                      width: 150,
                      height: 155,
                      onTap: () {
                        navigateToPage(
                          context,
                          MenuDietes(
                            userId: widget.userId,
                            pacienteId: isFamiliar ? relatedPatientId : '',
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> mostrarDialogoCerrarSesion(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Tancar sessió"),
            content: const Text("Estàs segur de que vols tancar la sessió?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                },
                child: const Text("Tancar sessió"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
