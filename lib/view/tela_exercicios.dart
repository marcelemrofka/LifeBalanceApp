import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

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

  void addExercise(String exercise) {
    if (timeController.text.isNotEmpty) {
      setState(() {
        exercises.add({
          'exercise': exercise,
          'time': timeController.text,
        });
      });
      timeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Exercícios', style: TextStyle(color: AppColors.lightText),),
        centerTitle: true,
        backgroundColor:AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
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

            Expanded(
              child: ListView.builder(
                itemCount: availableExercises.length,
                itemBuilder: (context, index) {
                  final exercise = availableExercises[index];
                  return InkWell(
                    onTap: () => addExercise(exercise),
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      color:AppColors.verdeNeutro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          exercise,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Icon(Icons.add, color:AppColors.principal),
                      ),
                    ),
                  );
                },
              ),
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
                ? Column(
                    children: exercises.map((exercise) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.fitness_center, color:AppColors.principal),
                          title: Text('${exercise['exercise']}'),
                          subtitle: Text('${exercise['time']} minutos'),
                        ),
                      );
                    }).toList(),
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
