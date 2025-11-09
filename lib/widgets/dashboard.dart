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

    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.33;
    final barWidth = screenWidth * 0.28;
    final horizontalPadding = screenWidth * 0.02;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Esquerda (Carboidratos e Fibras)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  progressBar(
                    "Carboidratos",
                    nutrition.carboIngerido,
                    nutrition.carboRecomendado,
                    barWidth,
                  ),
                  SizedBox(height: circleSize * 0.09),
                  progressBar(
                    "Fibras",
                    nutrition.fibraIngerida,
                    nutrition.fibraRecomendada,
                    barWidth,
                  ),
                ],
              ),

              // Círculo principal
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
                    currentPercentage: min(100, nutrition.caloriasPercentual),
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
                        style: const TextStyle(
                          fontSize: 21,
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
                      SizedBox(height: circleSize * 0.06),
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

              // Direita (Proteínas e Gorduras)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  progressBar(
                    "Proteínas",
                    nutrition.proteinaIngerida,
                    nutrition.proteinaRecomendada,
                    barWidth,
                  ),
                  SizedBox(height: circleSize * 0.09),
                  progressBar(
                    "Gorduras",
                    nutrition.gorduraIngerida,
                    nutrition.gorduraRecomendada,
                    barWidth,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: screenWidth * 0.05),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.midText,
            ),
            children: [
              const TextSpan(text: 'Sua meta de calorias diárias é: '),
              TextSpan(
                text:
                    '${nutrition.caloriasRecomendadas.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  color: AppColors.principal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
