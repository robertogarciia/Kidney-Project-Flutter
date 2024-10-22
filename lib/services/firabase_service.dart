import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsuario() async {
  List usuario = [];
  CollectionReference collectionReferenceUsuario = db.collection('Usuarios');

  QuerySnapshot queryUsuario = await collectionReferenceUsuario.get();

  for (var documento in queryUsuario.docs) {
    usuario.add(documento.data());
  }

  return usuario;
}

Future<void> addUsuario(String name, String email, String contrasenya) async {
  // Encriptar la contraseña usando SHA-256
  var bytes = utf8.encode(contrasenya);
  var digest = sha256.convert(bytes);
  var hashedPassword = digest.toString();

  // Agregar el usuario a la colección principal 'Usuarios'
  DocumentReference usuarioRef = await db.collection("Usuarios").add({
    "Nombre": name,
    "Email": email,
    "Contrasenya": hashedPassword,
  });


  /*Future<void> addUsuario(String name, String email, String contrasenya, String telefono) async {
  // Encriptar la contraseña usando SHA-256
  var bytes = utf8.encode(contrasenya);
  var digest = sha256.convert(bytes);
  var hashedPassword = digest.toString();

  // Agregar el usuario a la colección principal 'Usuarios'
  DocumentReference usuarioRef = await db.collection("Usuarios").add({
    "Nombre": name,
    "Email": email,
    "Contrasenya": hashedPassword,
  });

  // Agregar la información adicional (teléfono) a la subcolección 'DadesPersonals'
  await usuarioRef.collection("DadesPersonals").add({
    "Telefono": telefono,
  });
}*/
}
