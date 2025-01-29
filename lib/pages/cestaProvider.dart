import 'package:flutter/material.dart';

class CestaProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cestaItems = [];

  List<Map<String, dynamic>> get cestaItems => _cestaItems;

int get puntuacionTotal => _cestaItems.isEmpty 
    ? 0 
    : _cestaItems.map((item) => item['puntuacion'] as int).reduce((a, b) => a > b ? a : b);
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
  final index = _cestaItems.indexWhere((element) => element['item'] == item);
  if (index != -1) {
    _cestaItems.removeAt(index); 
    notifyListeners();
  }
}

    void vaciarCesta() {
    cestaItems.clear();
    notifyListeners();
  }
}
