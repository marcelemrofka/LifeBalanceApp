import 'package:flutter/material.dart';
import 'dart:math';

class TelaAgua extends StatefulWidget {
  @override
  _TelaAguaState createState() => _TelaAguaState();
}

class _TelaAguaState extends State<TelaAgua> with SingleTickerProviderStateMixin {
  double totalIngerido = 0;
  double capacidadeTotal = 2000; 
  int quantidadeSelecionada = 100;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

    _waveAnimation = Tween<double>(begin: 0, end: pi / 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void adicionarAgua() {
    setState(() {
      totalIngerido += quantidadeSelecionada;
      double progresso = (totalIngerido / capacidadeTotal).clamp(0.0, 1.0);
      _animation = Tween<double>(begin: _animation.value, end: progresso).animate(_controller);
      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF43644A), width: 10), 
                  ),
                  child: ClipOval(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_animation, _waveAnimation]),
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WaterPainter(_animation.value, _waveAnimation.value),
                          child: Container(),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  "${totalIngerido.toInt()} ml",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: quantidadeSelecionada,
              items: [100, 200, 300, 400, 500].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value ml"),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  quantidadeSelecionada = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarAgua,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43644A),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Adicionar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterPainter extends CustomPainter {
  final double progress;
  final double waveValue;

  WaterPainter(this.progress, this.waveValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint waterPaint = Paint()..color = Colors.blue;
    double waterHeight = size.height * (1 - progress);

    Path path = Path();
    for (double i = 0; i <= size.width; i++) {
      double waveHeight = 2 * sin((i / size.width * 4 * pi) + waveValue); 
      path.lineTo(i, waterHeight + waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, waterPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
