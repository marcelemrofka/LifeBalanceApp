import 'package:flutter/material.dart';

class TelaSobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Sobre o App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF43644A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: Color(0xFF43644A), size: 50),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ao LifeBalance!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF43644A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'O LifeBalance é um aplicativo inovador de contagem de calorias, desenvolvido para transformar sua rotina de saúde e bem-estar! Com recursos modernos e eficientes, você pode registrar sua ingestão de água, acompanhar sua alimentação, monitorar exercícios físicos, cadastrar lembretes e muito mais.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nosso objetivo é fornecer todas as ferramentas necessárias para que você alcance seus objetivos, seja para perda de peso, ganho de massa muscular ou manutenção de um estilo de vida equilibrado. O App foi desenvolvido pelas alunas Isa Marostegan Bertocco e Marcele Eduarda Mrofka Rufino.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tenha o controle da sua evolução na palma da mão!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF43644A),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
