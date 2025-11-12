import 'package:flutter/material.dart';
import 'dart:math';

class WaterCircleWidget extends StatelessWidget {
  final double totalIngerido;
  final double capacidadeTotal;
  final Animation<double> animation;
  final Animation<double> waveAnimation;

  const WaterCircleWidget({
    Key? key,
    required this.totalIngerido,
    required this.capacidadeTotal,
    required this.animation,
    required this.waveAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progresso = (totalIngerido / capacidadeTotal).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tamanho = min(constraints.maxWidth, constraints.maxHeight);
        final borderWidth = tamanho * 0.03;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 Círculo com recorte oval
              Container(
                width: tamanho,
                height: tamanho,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: borderWidth,
                  ),
                ),
                child: ClipOval(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([animation, waveAnimation]),
                    builder: (context, _) {
                      return CustomPaint(
                        painter: WaterPainter(
                          progress: progresso * animation.value,
                          waveValue: waveAnimation.value,
                        ),
                        size: Size(tamanho, tamanho),
                      );
                    },
                  ),
                ),
              ),

              // 🔹 Texto centralizado
              Text(
                "${totalIngerido.toInt()} ml",
                style: TextStyle(
                  fontSize: tamanho * 0.15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.7),
                      offset: const Offset(0, 0),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaterPainter extends CustomPainter {
  final double progress;
  final double waveValue;

  WaterPainter({required this.progress, required this.waveValue});

  @override
  void paint(Canvas canvas, Size size) {
    final waterPaint = Paint()..color = const Color(0xFF81B5DF);
    final waterHeight = size.height * (1 - progress);

    const amplitude = 4.0;
    const waves = 2.0;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight +
          amplitude * sin((x / size.width * waves * pi) + waveValue);
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, waterPaint);
  }

  @override
  bool shouldRepaint(covariant WaterPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.waveValue != waveValue;
}
