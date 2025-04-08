import 'dart:convert';
import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaExercicios extends StatefulWidget {
  @override
  _TelaExerciciosState createState() => _TelaExerciciosState();
}

class _TelaExerciciosState extends State<TelaExercicios> {
  final List<String> availableExercises = [
    'Corrida',
    'Caminhada',
    'Natação',
    'Bicicleta',
    'Levantamento de Peso',
    'Flexões',
    'Abdominais',
  ];

  final List<Map<String, String>> exercises = [];
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('exercises');
    if (savedData != null) {
      List<dynamic> decoded = jsonDecode(savedData);
      setState(() {
        exercises.addAll(decoded.map((e) => Map<String, String>.from(e)));
      });
    }
  }

  void _saveExercises() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('exercises', jsonEncode(exercises));
  }

  void addExercise(String exercise) {
    if (timeController.text.isNotEmpty) {
      setState(() {
        exercises.add({
          'exercise': exercise,
          'time': timeController.text,
        });
      });
      _saveExercises();
      timeController.clear();
    }
  }

  void removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
    _saveExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Exercícios', style: TextStyle(color: AppColors.lightText)),
        centerTitle: true,
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Tempo (em minutos)',
                prefixIcon: Icon(Icons.timer, color: AppColors.verdeClaro),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Toque para adicionar:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                return InkWell(
                  onTap: () => addExercise(exercise),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    color: AppColors.verdeNeutro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        exercise,
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(Icons.add, color: AppColors.principal),
                    ),
                  ),
                );
              },
            ),
            Divider(thickness: 1.5, height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Exercícios Registrados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            exercises.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.fitness_center, color: AppColors.principal),
                          title: Text('${exercise['exercise']}'),
                          subtitle: Text('${exercise['time']} minutos'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: AppColors.principal),
                            onPressed: () => removeExercise(index),
                          ),
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Nenhum exercício registrado!',
                      style: TextStyle(color: AppColors.midText),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
