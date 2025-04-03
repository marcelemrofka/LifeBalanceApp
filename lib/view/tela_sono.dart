import 'package:flutter/material.dart';

class TelaSono extends StatefulWidget {
  @override
  _TelaSonoState createState() => _TelaSonoState();
}

class _TelaSonoState extends State<TelaSono> {
  TimeOfDay? _horaSono;
  TimeOfDay? _horaDespertar;
  String _totalHorasDormidas = "";

  void _calcularHorasDormidas() {
    if (_horaSono != null && _horaDespertar != null) {
      final DateTime agora = DateTime.now();
      final DateTime horaSono = DateTime(agora.year, agora.month, agora.day, _horaSono!.hour, _horaSono!.minute);
      final DateTime horaDespertar = DateTime(agora.year, agora.month, agora.day, _horaDespertar!.hour, _horaDespertar!.minute);

      int horasDormidas = 0;
      
      if (horaDespertar.isBefore(horaSono)) {
        horasDormidas = horaDespertar.add(Duration(days: 1)).difference(horaSono).inHours;
      } else {
        horasDormidas = horaDespertar.difference(horaSono).inHours;
      }

      setState(() {
        _totalHorasDormidas = "$horasDormidas horas";
      });

      if (horasDormidas < 7) {
        _mostrarAlerta("Você dormiu pouco! Menos de 7 horas de sono.");
      } else if (horasDormidas > 9) {
        _mostrarAlerta("Você dormiu demais! Mais de 9 horas de sono.");
      }
      else{
        _mostrarAlerta("Parabéns! Você teve uma boa quantidade de horas de sono!");
      }
    }
  }

  void _mostrarAlerta(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Atenção"),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selecionarHora(TimeOfDay initialTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      onTimeSelected(selectedTime);
      _calcularHorasDormidas();  
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Sono'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          color: Colors.green[100], 
        ),
      ),
      body: Center( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center,  
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,  
                children: [
                  Text(
                    "Hora de dormir:",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selecionarHora(TimeOfDay.now(), (time) {
                      setState(() {
                        _horaSono = time;
                      });
                    }),
                    child: Text(_horaSono != null ? _horaSono!.format(context) : "Selecionar hora"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,  
                children: [
                  Text(
                    "Hora de despertar:",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selecionarHora(TimeOfDay.now(), (time) {
                      setState(() {
                        _horaDespertar = time;
                      });
                    }),
                    child: Text(_horaDespertar != null ? _horaDespertar!.format(context) : "Selecionar hora"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              _totalHorasDormidas.isNotEmpty
                  ? Text(
                      "Total de horas dormidas: $_totalHorasDormidas",
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
