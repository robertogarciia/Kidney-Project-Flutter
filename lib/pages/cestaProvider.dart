import 'package:flutter/material.dart';

class CestaProvider with ChangeNotifier {
  // Llista interna per guardar els elements de la cistella
  List<Map<String, dynamic>> _cestaItems = [];

  // Getter per obtenir els elements de la cistella
  List<Map<String, dynamic>> get cestaItems => _cestaItems;

  // Getter per obtenir la puntuació total. Agafa la puntuació més alta dels items
  int get puntuacionTotal => _cestaItems.isEmpty
      ? 0  // Si la cistella està buida, la puntuació és 0
      : _cestaItems.map((item) => item['puntuacion'] as int).reduce((a, b) => a > b ? a : b);  // Agafa la puntuació màxima

  // Getter per obtenir l'ID de l'usuari (en aquest cas, retorna null)
  get userId => null;

  // Funció per afegir un element a la cistella
  void agregarItem(String item, int puntuacion, String imageUrl) {
    // Comprovem si la cistella ja té 4 elements
    if (_cestaItems.length < 4) {
      // Afegim l'element amb el seu nom, puntuació i URL d'imatge
      _cestaItems.add({
        'item': item,
        'puntuacion': puntuacion,
        'imageUrl': imageUrl,
      });
      // Notifiquem als listeners que hi ha hagut un canvi
      notifyListeners();
    } else {
      // Si la cistella té 4 elements, no es pot afegir més
      print('No es posible agregar más de 4 elementos a la cesta');
    }
  }

  // Funció per eliminar un element de la cistella
  void eliminarItem(String item) {
    // Busquem l'índex de l'element que volem eliminar
    final index = _cestaItems.indexWhere((element) => element['item'] == item);
    if (index != -1) {
      // Eliminem l'element de la llista
      _cestaItems.removeAt(index);
      // Notifiquem als listeners que hi ha hagut un canvi
      notifyListeners();
    }
  }

  // Funció per buidar tota la cistella
  void vaciarCesta() {
    // Buidem la llista de la cistella
    cestaItems.clear();
    // Notifiquem als listeners que la cistella ha estat buidada
    notifyListeners();
  }
}
