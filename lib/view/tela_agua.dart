import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _waveAnimation = Tween<double>(begin: 0, end: pi / 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _carregarTotalIngerido();
  }

  Future<void> _carregarTotalIngerido() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('agua').doc(uid).get();

      if (doc.exists) {
        setState(() {
          totalIngerido = (doc.data()?['quantidade'] ?? 0).toDouble();
          double progresso = (totalIngerido / capacidadeTotal).clamp(0.0, 1.0);
          _animation = Tween<double>(begin: 0, end: progresso).animate(_controller);
          _controller.forward(from: 0);
        });
      }
    }
  }

  Future<void> _salvarTotalIngerido() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('agua').doc(uid).set({
        'quantidade': totalIngerido,
      }, SetOptions(merge: true));
    }
  }

  void adicionarAgua() {
    setState(() {
      totalIngerido += quantidadeSelecionada;
      double progresso = (totalIngerido / capacidadeTotal).clamp(0.0, 1.0);
      _animation = Tween<double>(begin: _animation.value, end: progresso).animate(_controller);
      _controller.forward(from: 0);
    });
    _salvarTotalIngerido();
  }

  void resetarAgua() {
    setState(() {
      totalIngerido = 0;
      _animation = Tween<double>(begin: _animation.value, end: 0).animate(_controller);
      _controller.forward(from: 0);
    });
    _salvarTotalIngerido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cadastro de Água', style: TextStyle(color: AppColors.lightText)),
        centerTitle: true,
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.lightText),
            onPressed: resetarAgua,
            tooltip: 'Resetar ingestão',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.principal, width: 5),
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
              items: [100, 200, 300, 400, 500, 1000].map((int value) {
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
                backgroundColor: AppColors.principal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Adicionar", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 30),
            Text(
              'Insira a quantidade ingerida de água hoje!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.midText),
            ),
            SizedBox(height: 30),
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
