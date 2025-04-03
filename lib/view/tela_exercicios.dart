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
        title: const Text('Cadastro de Exercícios'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Tempo (em minutos)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: availableExercises
                    .map((exercise) {
                  return GestureDetector(
                    onTap: () => addExercise(exercise),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exercise,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Icon(Icons.add, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
           Center(
            child: Text(
              'Exercícios Registrados:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ),         

            const SizedBox(height: 10),
            exercises.isNotEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '${exercise['exercise']} - ${exercise['time']} minutos',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text('Nenhum exercício registrado!'),
                  ),
          ],
        ),
      ),
    );
  }
}
