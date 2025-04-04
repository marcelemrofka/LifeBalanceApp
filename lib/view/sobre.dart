import 'package:flutter/material.dart';

class TelaSobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sobre o App'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'O LifeBalance aplicativo inovador de contagem de calorias, desenvolvido para transformar sua rotina de saúde e bem-estar! Com recursos modernos e eficientes, você pode registrar sua ingestão de água, acompanhar sua alimentação, monitorar exercícios físicos, cadastrar lembretes e muito mais.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16),
              Text(
                'Nosso objetivo é fornecer todas as ferramentas necessárias para que você alcance seus objetivos, seja para perda de peso, ganho de massa muscular ou manutenção de um estilo de vida equilibrado.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16),
              Text(
                'Tenha o controle da sua evolução na palma da mão!',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
