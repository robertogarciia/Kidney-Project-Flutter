import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kidneyproject/pages/laMevaDietaDetall.dart';

class lesMevesDietes extends StatefulWidget {
  final String userId;
  final String tipusC;

  const lesMevesDietes({Key? key, required this.userId, required this.tipusC})
      : super(key: key);

  @override
  _lesMevesDietesState createState() => _lesMevesDietesState();
}

class _lesMevesDietesState extends State<lesMevesDietes> {
  String _currentFilter = 'today';
  bool _isDescending = true;
  DateTime? _selectedDate;
  List<QueryDocumentSnapshot> _dietes = [];

  Future<void> _fetchDietes() async {
    final collection = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .collection('resumDietes');

    final DateTime today = DateTime.now();
    Query query = collection;

    if (_currentFilter == 'today') {
      query = query
          .where('fechaCreacion',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day)))
          .where('fechaCreacion',
              isLessThan: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day + 1)));
    } else if (_currentFilter == 'calendar' && _selectedDate != null) {
      final DateTime selectedDateStart = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final DateTime selectedDateEnd =
          selectedDateStart.add(const Duration(days: 1));
      query = query
          .where('fechaCreacion',
              isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDateStart))
          .where('fechaCreacion',
              isLessThan: Timestamp.fromDate(selectedDateEnd));
    }

    final snapshot = await query.get();
    setState(() {
      _dietes = snapshot.docs;
    });
  }

  void _sortDietes() {
    _dietes.sort((a, b) {
      final puntuacionA = a['puntuacionTotal'] ?? 0;
      final puntuacionB = b['puntuacionTotal'] ?? 0;
      return _isDescending
          ? puntuacionB.compareTo(puntuacionA)
          : puntuacionA.compareTo(puntuacionB);
    });
  }

  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _currentFilter = 'calendar';
        _dietes = [];
      });
      _fetchDietes();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDietes();
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
        .doc(widget.userId)
        .collection('resumDietes');

    try {
      await userRef.doc(dietaId).delete();
      setState(() {
        _dietes.removeAt(index);
      });
      _fetchDietes();
    } catch (e) {
      print("Error al eliminar la dieta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les Meves Dietes'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isDescending = !_isDescending;
                          _sortDietes();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDescending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDescending
                                ? 'Puntuació Descendent'
                                : 'Puntuació Ascendent',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = 'today';
                          _selectedDate = null;
                          _dietes = [];
                        });
                        _fetchDietes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                      ),
                      child: const Text(
                        'Restablir filtres',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _showDatePicker,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text(
                    'Selecciona una data',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentFilter == 'today'
                  ? 'Dietes d\'Avui'
                  : (_currentFilter == 'calendar' && _selectedDate != null
                      ? 'Dieta del: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Totes les Meves Dietes'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: Text(nombre),
                            subtitle: Text(
                              'Puntuació Total: $puntuacionTotal\nCreada el: ${DateFormat('dd/MM/yyyy').format(fechaCreacion)}',
                            ),
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
                                    nombre: nombre,
                                    fechaCreacion: fechaCreacion,
                                    puntuacionTotal: puntuacionTotal,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
