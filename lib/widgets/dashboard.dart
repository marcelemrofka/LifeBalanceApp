import 'dart:math';
import 'package:app/utils/color.dart';
import 'package:app/viewmodel/nutrition_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percentages_with_animation/percentages_with_animation.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NutritionViewModel>(context, listen: false)
          .buscarDadosDoHistorico();
    });
  }

  Widget progressBar(
      String label, double gramas, double maxGramas, double width) {
    double porcentagem = min(100, (gramas / maxGramas) * 100);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
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

    final circleSize = screenWidth * 0.35;
    final barWidth = screenWidth * 0.28;
    final horizontalPadding = screenWidth * 0.02;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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

              // Círculo principal (verde escuro)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Fundo verde escuro
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      color: AppColors.principal,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Borda animada
                  CircularPercentage(
                    currentPercentage: min(100, nutrition.caloriasPercentual),
                    maxPercentage: 100,
                    size: circleSize,
                    percentageStrokeWidth: circleSize * 0.035,
                    backgroundStrokeWidth: 1,
                    backgroundColor: Colors.transparent,
                    percentageColor: AppColors.verdeGrafico,
                    centerText: '',
                  ),

                  // Conteúdo interno
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${nutrition.caloriasIngeridas.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 21, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: circleSize * 0.03),
                      Text(
                        "Consumidas",
                        style: TextStyle(
                          fontSize: circleSize * 0.08,
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
                  SizedBox(height: circleSize * 0.09), // Proportional spacing
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

        SizedBox(
            height: screenWidth *
                0.05), // Espaçamento proporcional entre os gráficos e o texto

        // RichText abaixo dos gráficos
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: screenWidth * 0.032, // Fonte proporcional
              color: AppColors.midText,
            ),
            children: [
              const TextSpan(text: 'Sua meta de calorias diárias é: '),
              TextSpan(
                text:
                    '${nutrition.caloriasRecomendadas.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: screenWidth * 0.032, // Fonte proporcional
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
