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
        title: Text('Lembretes'),
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibe o calendário
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
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              TextField(
                controller: _lembreteController,
                decoration: InputDecoration(
                  labelText: 'Escreva seu lembrete',
                   border: OutlineInputBorder(),
              ),

              ),
              SizedBox(height: 10),
             
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lembretes[_selectedDay] = _lembreteController.text; 
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lembrete salvo!')),
                  );
                },
                child: Text('Salvar Lembrete'),
              ),
              SizedBox(height: 20),
              
              _lembretes.isNotEmpty
                  ? Column(
                      children: _lembretes.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '${_formatDate(entry.key)}: ${entry.value}',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}