import 'dart:async';
import 'dart:math';
import 'package:app/utils/color.dart';
import 'package:app/viewmodel/nutrition_vm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percentages_with_animation/percentages_with_animation.dart';

class Dashboard extends StatefulWidget {
  final String? uidPaciente; // 🔹 novo parâmetro opcional

  const Dashboard({super.key, this.uidPaciente});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    // Caso o nutricionista tenha passado um UID de paciente,
    // usamos ele — caso contrário, usamos o usuário logado.
    final uidParaBuscar =
        widget.uidPaciente ?? FirebaseAuth.instance.currentUser?.uid;

    if (uidParaBuscar != null) {
      Provider.of<NutritionViewModel>(context, listen: false)
          .buscarMetasDoPaciente(uidParaBuscar);
    }

    // Escuta troca de usuário (só útil no caso paciente logado)
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (widget.uidPaciente == null && user != null) {
        Provider.of<NutritionViewModel>(context, listen: false)
            .buscarMetasDoPaciente(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Widget progressBar(
      String label, double gramas, double maxGramas, double width) {
    double porcentagem = (maxGramas > 0 && gramas >= 0)
        ? min(100, (gramas / maxGramas) * 100)
        : 0;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.midText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: width,
          child: LinearPercentage(
            currentPercentage: porcentagem,
            maxPercentage: 100,
            backgroundHeight: 8,
            percentageHeight: 8,
            leftRightText: LeftRightText.none,
            backgroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200,
            ),
            percentageDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.verdeGrafico,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${gramas.toStringAsFixed(0)}g',
          style: const TextStyle(fontSize: 12, color: AppColors.midText),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  final nutrition = Provider.of<NutritionViewModel>(context);

  if (nutrition.carregando) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.principal),
    );
  }

  final size = MediaQuery.of(context).size;
  final screenWidth = size.width;
  final screenHeight = size.height;

  // 🔹 Proporções dinâmicas baseadas no menor lado da tela
  final baseSize = min(screenWidth, screenHeight);
  final circleSize = baseSize * 0.33;
  final barWidth = baseSize * 0.25;
  final horizontalPadding = screenWidth * 0.04;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // 🔹 Verifica se a tela é estreita (modo retrato)
        final isPortrait = constraints.maxWidth < 600;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔸 Parte superior (gráficos)
            if (isPortrait)
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildDashboardContent(
                      circleSize, barWidth, nutrition, true),
                  SizedBox(height: screenHeight * 0.04),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDashboardContent(
                        circleSize, barWidth, nutrition, false),
                  ),
                ],
              ),

            // 🔸 Texto inferior
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.015),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: baseSize * 0.032,
                    color: AppColors.midText,
                  ),
                  children: [
                    const TextSpan(text: 'Sua meta de calorias diárias é: '),
                    TextSpan(
                      text:
                          '${nutrition.caloriasRecomendadas.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: baseSize * 0.034,
                        fontWeight: FontWeight.bold,
                        color: AppColors.principal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}


Widget _buildDashboardContent(double circleSize, double barWidth,
    NutritionViewModel nutrition, bool isPortrait) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Esquerda
      Flexible(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            progressBar("Carboidratos", nutrition.carboIngerido,
                nutrition.carboRecomendado, barWidth),
            SizedBox(height: circleSize * 0.08),
            progressBar("Fibras", nutrition.fibraIngerida,
                nutrition.fibraRecomendada, barWidth),
          ],
        ),
      ),

      // Círculo central
      Flexible(
        flex: 3,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    color: AppColors.principal,
                    shape: BoxShape.circle,
                  ),
                ),
                CircularPercentage(
                  currentPercentage:
                      min(100, nutrition.caloriasPercentual),
                  maxPercentage: 100,
                  size: circleSize,
                  percentageStrokeWidth: circleSize * 0.033,
                  backgroundStrokeWidth: 1,
                  backgroundColor: Colors.transparent,
                  percentageColor: AppColors.verdeGrafico,
                  centerText: '',
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${nutrition.caloriasIngeridas.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: circleSize * 0.15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: circleSize * 0.03),
                    const Text(
                      "Consumidas",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: circleSize * 0.05),
                    Text(
                      "Você já atingiu ${nutrition.caloriasPercentual.toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: circleSize * 0.07,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // Direita
      Flexible(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            progressBar("Proteínas", nutrition.proteinaIngerida,
                nutrition.proteinaRecomendada, barWidth),
            SizedBox(height: circleSize * 0.08),
            progressBar("Gorduras", nutrition.gorduraIngerida,
                nutrition.gorduraRecomendada, barWidth),
          ],
        ),
      ),
    ],
  );
}
}