import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/utils/color.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaLembretes extends StatefulWidget {
  @override
  _TelaLembretesState createState() => _TelaLembretesState();
}

class _TelaLembretesState extends State<TelaLembretes> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  // Map of date -> { 'titulo': string, 'descricao': string, 'docId': string }
  Map<DateTime, Map<String, dynamic>> _lembretes = {};

  @override
  void initState() {
    super.initState();
    _loadLembretes();
  }

  void _loadLembretes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not signed in, keep map empty
      setState(() {
        _lembretes = {};
      });
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('lembretes')
        .where('uid_usuario', isEqualTo: user.uid)
        .get();

    final Map<DateTime, Map<String, dynamic>> fetched = {};
    for (final doc in query.docs) {
      final data = doc.data();
      // Expecting 'data' as Timestamp or ISO string
      DateTime date;
      if (data['data'] is Timestamp) {
        date = (data['data'] as Timestamp).toDate();
      } else if (data['data'] is String) {
        date = DateTime.parse(data['data']);
      } else {
        continue; // skip malformed
      }
      final key = DateTime(date.year, date.month, date.day);
      fetched[key] = {
        'titulo': data['titulo'] ?? '',
        'descricao': data['descricao'] ?? '',
        'docId': doc.id,
      };
    }

    setState(() {
      _lembretes = fetched;
      final todayKey =
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      _tituloController.text = _lembretes[todayKey]?['titulo'] ?? '';
      _descricaoController.text = _lembretes[todayKey]?['descricao'] ?? '';
    });
  }

  void _deleteLembrete(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final entry = _lembretes[key];
    if (entry != null && entry['docId'] != null) {
      FirebaseFirestore.instance
          .collection('lembretes')
          .doc(entry['docId'])
          .delete();
    }

    setState(() {
      _lembretes.remove(key);
      if (isSameDay(date, _selectedDay)) {
        _tituloController.clear();
        _descricaoController.clear();
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Lembretes'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _selectedDay,
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  final key = DateTime(
                      selectedDay.year, selectedDay.month, selectedDay.day);
                  _tituloController.text = _lembretes[key]?['titulo'] ?? '';
                  _descricaoController.text =
                      _lembretes[key]?['descricao'] ?? '';
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: AppColors.principal),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: AppColors.principal),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.principal,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.principal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lembrete para ${_formatDate(_selectedDay)}:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Título do lembrete',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                hintText: 'Descrição do lembrete',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final hoje = DateTime.now();
                  final dataSelecionada = DateTime(
                      _selectedDay.year, _selectedDay.month, _selectedDay.day);
                  final dataAtual = DateTime(hoje.year, hoje.month, hoje.day);

                  if (dataSelecionada.isBefore(dataAtual)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Atenção! Você está tentando cadastrar em uma data antiga.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuário não autenticado.')),
                      );
                      return;
                    }

                    final key = DateTime(dataSelecionada.year,
                        dataSelecionada.month, dataSelecionada.day);

                    // If there's already a doc for this date, update it. Otherwise create new.
                    final existing = _lembretes[key];

                    final dataToSave = {
                      'data': Timestamp.fromDate(dataSelecionada),
                      'titulo': _tituloController.text.trim(),
                      'descricao': _descricaoController.text.trim(),
                      'uid_usuario': user.uid,
                    };

                    if (existing != null && existing['docId'] != null) {
                      FirebaseFirestore.instance
                          .collection('lembretes')
                          .doc(existing['docId'])
                          .update(dataToSave);
                      setState(() {
                        _lembretes[key] = {
                          'titulo': dataToSave['titulo'],
                          'descricao': dataToSave['descricao'],
                          'docId': existing['docId'],
                        };
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('lembretes')
                          .add(dataToSave)
                          .then((docRef) {
                        setState(() {
                          _lembretes[key] = {
                            'titulo': dataToSave['titulo'],
                            'descricao': dataToSave['descricao'],
                            'docId': docRef.id,
                          };
                        });
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lembrete salvo!')),
                    );
                  }
                },
                label: Text('Salvar Lembrete'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja),
              ),
            ),
            SizedBox(height: 30),
            if (_lembretes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Todos os lembretes:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ..._lembretes.entries.map((entry) {
                    final date = entry.key;
                    final value = entry.value;
                    return Card(
                      color: AppColors.verdeClarinho,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading:
                            Icon(Icons.event_note, color: AppColors.principal),
                        title: Text(_formatDate(date)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((value['titulo'] ?? '').isNotEmpty)
                              Text(value['titulo']),
                            if ((value['descricao'] ?? '').isNotEmpty)
                              Text(value['descricao']),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: AppColors.laranja),
                          onPressed: () => _deleteLembrete(date),
                        ),
                        onTap: () {
                          // When tapped, select the date and populate controllers
                          setState(() {
                            _selectedDay = date;
                            _tituloController.text = value['titulo'] ?? '';
                            _descricaoController.text =
                                value['descricao'] ?? '';
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
