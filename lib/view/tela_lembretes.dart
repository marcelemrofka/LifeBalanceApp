import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaLembretes extends StatefulWidget {
  @override
  _TelaLembretesState createState() => _TelaLembretesState();
}

class _TelaLembretesState extends State<TelaLembretes> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _lembreteController = TextEditingController();
  Map<DateTime, String> _lembretes = {};

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lembretes', style: TextStyle(color: AppColors.lightText),),
        backgroundColor: AppColors.principal,
        centerTitle: true,
      ),
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
                  _lembreteController.text = _lembretes[selectedDay] ?? '';
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.principal),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.principal),
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
              controller: _lembreteController,
              decoration: InputDecoration(
                hintText: 'Escreva seu lembrete',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _lembretes[_selectedDay] = _lembreteController.text;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lembrete salvo!')),
                  );
                },
                icon: Icon(Icons.save),
                label: Text('Salvar Lembrete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.principal,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
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
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(Icons.event_note, color: AppColors.principal),
                        title: Text(
                          _formatDate(entry.key),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(entry.value),
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
