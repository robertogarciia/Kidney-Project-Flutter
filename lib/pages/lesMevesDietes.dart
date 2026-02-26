import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kidneyproject/pages/laMevaDietaDetall.dart';

class lesMevesDietes extends StatefulWidget {
  final String userId;
  final bool mostrarSoloPropias; // Nuevo parámetro
  final String? pacienteId; // Si viene de otra página

  const lesMevesDietes({
    Key? key,
    required this.userId,
    required this.pacienteId,
    this.mostrarSoloPropias = false,
  }) : super(key: key);

  @override
  _lesMevesDietesState createState() => _lesMevesDietesState();
}

class _lesMevesDietesState extends State<lesMevesDietes> {
  String _currentFilter = 'today';
  bool _isDescending = true;
  DateTime? _selectedDate;
  List<QueryDocumentSnapshot> _dietes = [];
  String _userType = '';
  bool _mostrarFavorits = false;
  bool _isLoading = true;
  String _tituloAppBar = 'Les Meves Dietes';
  late String _targetUserId; // usuario real al que consultar dietas

  Future<void> _initializePage() async {
    await _loadUserData();
    await _fetchDietes();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _loadUserData() async {
    // ✅ Si recibimos pacienteId, usamos directamente
    if (widget.pacienteId != null && !widget.mostrarSoloPropias) {
      setState(() {
        _targetUserId = widget.pacienteId!;
        _tituloAppBar = 'Les Dietes del Pacient';
      });
      return; // ya no hace falta nada más
    }

    // Caso normal: usuario propio
    setState(() {
      _targetUserId = widget.userId;
      _tituloAppBar = 'Les Meves Dietes';
    });
  }

  Future<void> _fetchDietes() async {
    final collection = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_targetUserId)
        .collection('resumDietes');

    Query query = collection;
    final today = DateTime.now();

    if (_currentFilter == 'today') {
      query = query
          .where('fechaCreacion',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day)))
          .where('fechaCreacion',
              isLessThan: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day + 1)));
    } else if (_currentFilter == 'calendar' && _selectedDate != null) {
      final start = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final end = start.add(const Duration(days: 1));

      query = query
          .where('fechaCreacion',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('fechaCreacion', isLessThan: Timestamp.fromDate(end));
    }

    final snapshot = await query.get();
    List<QueryDocumentSnapshot> dietes = snapshot.docs;

    if (_mostrarFavorits) {
      dietes = dietes.where((d) => d['favorito'] == true).toList();
    }

    setState(() => _dietes = dietes);
  }

  void _sortDietes() {
    _dietes.sort((a, b) {
      final aScore = a['puntuacionTotal'] ?? 0;
      final bScore = b['puntuacionTotal'] ?? 0;
      return _isDescending
          ? bScore.compareTo(aScore)
          : aScore.compareTo(bScore);
    });
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _currentFilter = 'calendar';
        _dietes = [];
      });
      _fetchDietes();
    }
  }

  void _toggleDietas() {
    setState(() {
      _currentFilter = _currentFilter == 'today' ? 'all' : 'today';
      _dietes = [];
    });
    _fetchDietes();
  }

  Future<void> _deleteDiet(String dietaId, int index) async {
    final userRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_targetUserId)
        .collection('resumDietes');

    try {
      await userRef.doc(dietaId).delete();
      setState(() => _dietes.removeAt(index));
      _fetchDietes();
    } catch (e) {
      print("Error al eliminar la dieta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botones de orden y restablecer filtros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isDescending = !_isDescending);
                    _sortDietes();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Row(
                    children: [
                      Icon(
                          _isDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                          _isDescending
                              ? 'Puntuació Descendent'
                              : 'Puntuació Ascendent',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentFilter = 'today';
                      _selectedDate = null;
                      _dietes = [];
                      _mostrarFavorits = false;
                    });
                    _fetchDietes();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text('Restablir filtres',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Selector de fecha y favoritos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showDatePicker,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text('Selecciona una data',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12)),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 6),
                          const Text('Favorits',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          Switch(
                              value: _mostrarFavorits,
                              activeColor: Colors.amber,
                              onChanged: (val) {
                                setState(() => _mostrarFavorits = val);
                                _fetchDietes();
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentFilter == 'today'
                  ? 'Dietes d\'Avui'
                  : (_currentFilter == 'calendar' && _selectedDate != null
                      ? 'Dieta del: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Totes les Dietes'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Lista de dietas
            Expanded(
              child: _dietes.isEmpty
                  ? Center(
                      child: Text(
                        _currentFilter == 'today'
                            ? 'No tens cap dieta registrada per avui'
                            : 'No tens cap dieta registrada',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dietes.length,
                      itemBuilder: (context, index) {
                        final dieta = _dietes[index];
                        final nombre = dieta['nombre'] ?? 'Sense nom';
                        final fechaCreacion =
                            (dieta['fechaCreacion'] as Timestamp).toDate();
                        final puntuacionTotal = dieta['puntuacionTotal'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          child: ListTile(
                            title: Text(nombre),
                            subtitle: Text(
                                'Puntuació Total: $puntuacionTotal\nCreada el: ${DateFormat('dd/MM/yyyy').format(fechaCreacion)}'),
                            trailing: Icon(
                              puntuacionTotal <= 3
                                  ? Icons.check_circle
                                  : puntuacionTotal <= 6
                                      ? Icons.info
                                      : Icons.warning,
                              color: puntuacionTotal <= 2
                                  ? Colors.green
                                  : puntuacionTotal <= 6
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => laMevaDietaDetall(
                                    userId: _targetUserId,
                                    nombre: nombre,
                                    fechaCreacion: fechaCreacion,
                                    puntuacionTotal: puntuacionTotal,
                                    esFavorito: dieta['favorito'] ?? false,
                                    alimentos: dieta['alimentos'] ?? [],
                                    dietaId: dieta.id,
                                    onDelete: (String dietaId) async {
                                      await _deleteDiet(dietaId, index);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
        child: ElevatedButton(
          onPressed: _toggleDietas,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            _currentFilter == 'today'
                ? 'Veure Totes les Dietes'
                : 'Veure Dietes d\'Avui',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
