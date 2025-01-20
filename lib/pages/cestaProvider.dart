import 'package:flutter/material.dart';

class CestaProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cestaItems = [];

  List<Map<String, dynamic>> get cestaItems => _cestaItems;

  int get puntuacionTotal => _cestaItems.fold(0, (total, item) => total + item['puntuacion'] as int);

  get userId => null;

void agregarItem(String item, int puntuacion, String imageUrl) {
  if (_cestaItems.length < 4) {
    _cestaItems.add({
      'item': item,
      'puntuacion': puntuacion,
      'imageUrl': imageUrl,
    });
    notifyListeners();
  } else {
    print('No es posible agregar más de 4 elementos a la cesta');
  }
}


  void eliminarItem(String item) {
    _cestaItems.removeWhere((element) => element['item'] == item);
    notifyListeners();
  }
    void vaciarCesta() {
    cestaItems.clear();
    notifyListeners();
  }
}
