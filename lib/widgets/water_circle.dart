import 'package:flutter/material.dart';
import 'dart:math';
import 'package:app/utils/color.dart';

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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.midGrey, width: 8),
          ),
          child: ClipOval(
            child: AnimatedBuilder(
              animation: Listenable.merge([animation, waveAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: WaterPainter(animation.value, waveAnimation.value),
                  child: Container(),
                );
              },
            ),
          ),
        ),
        Text(
          "${totalIngerido.toInt()} ml",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
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
