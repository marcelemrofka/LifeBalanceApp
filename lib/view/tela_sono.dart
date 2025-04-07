import 'package:app/utils/color.dart';
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
      } else {
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
            TextButton(onPressed: () => Navigator.of(context).pop(),child: Text("OK")),
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

  Widget _buildHoraCard(String label, TimeOfDay? time, VoidCallback onPressed, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.verdeClaro),
        title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(time != null ? time.format(context) : "Hora não selecionada"),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.principal),
          icon: Icon(Icons.access_time),
          label: Text("Selecionar"),
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Sono', style: TextStyle(color: AppColors.lightText),),
        backgroundColor: AppColors.principal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText,),onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Informe os horários de sono e despertar para saber quanto tempo você dormiu.",
              style: TextStyle(fontSize: 16, color: AppColors.midText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            _buildHoraCard(
              "Hora de dormir",
              _horaSono,
              () => _selecionarHora(TimeOfDay.now(), (time) {
                setState(() {
                  _horaSono = time;
                });
              }),
              Icons.bedtime,
            ),

            _buildHoraCard(
              "Hora de despertar",
              _horaDespertar,
              () => _selecionarHora(TimeOfDay.now(), (time) {
                setState(() {
                  _horaDespertar = time;
                });
              }),
              Icons.wb_sunny,
            ),

            SizedBox(height: 30),
            if (_totalHorasDormidas.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nightlight_round, color: AppColors.verdeClaro),
                    SizedBox(width: 10),
                    Text("Total dormido: $_totalHorasDormidas",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.midText),),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
