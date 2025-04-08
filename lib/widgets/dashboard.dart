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
  
  Widget progressBar(String label, double gramas, double maxGramas) {
    double porcentagem = min(100, (gramas / maxGramas) * 100);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 150,
            child: Text(label),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 150,
          child: LinearPercentage(
            currentPercentage: porcentagem,
            maxPercentage: 100,
            backgroundHeight: 10,
            percentageHeight: 10,
            leftRightText: LeftRightText.none,
            backgroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300,
            ),
            percentageDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.verdeGrafico,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${gramas.toStringAsFixed(0)}g',
          style: const TextStyle(fontSize: 12, color: AppColors.midText),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final nutrition = Provider.of<NutritionViewModel>(context).nutrition;
     
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Circulo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180, 
                decoration: const BoxDecoration(color: AppColors.principal, shape: BoxShape.circle,),
              ),

              // porcentagem ao redor
              CircularPercentage(
                  currentPercentage: min(100, nutrition.caloriasPercentual), // limita a 100%
                  maxPercentage: 100, 
                  size: 180,
                  percentageStrokeWidth: 7, 
                  backgroundStrokeWidth: 1,
                  percentageColor: AppColors.verdeGrafico,
                  centerText: '', // precisa ser vazio para ser sobreposto
                ),

                // Textos dentro do circulo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${nutrition.caloriasIngeridas.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    ),
                    SizedBox(height: 4),
                    const Text("Consumidas", style: TextStyle(fontSize: 12, color: Colors.white)),
                    SizedBox(height: 12),
                    Text(
                      "Você consumiu ${nutrition.caloriasPercentual.toStringAsFixed(0)}%",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 15),


          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color:AppColors.midText,
                fontWeight: FontWeight.w100,
              ),
              children: const [
                TextSpan(text: 'Sua meta de calorias diárias é: ',),
                TextSpan(
                  text: '1800 kcal',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),
          // NUTRIENTES 
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                // Carb e Fibras
                Column(
                  children: [
                      progressBar("Carboidratos", nutrition.carboIngerido.toDouble(), nutrition.carboRecomendado.toDouble()),
                       SizedBox(height: 15),
                      progressBar("Fibras", nutrition.fibraIngerida.toDouble(), nutrition.fibraRecomendada.toDouble()),
                  ],
                ),

                // Proteinas e Gorduras 
                Column(
                  children: [
                    progressBar("Proteínas", nutrition.proteinaIngerida.toDouble(), nutrition.proteinaRecomendada.toDouble()),
                    SizedBox(height: 15),
                    progressBar("Gorduras", nutrition.gorduraIngerida.toDouble(), nutrition.gorduraRecomendada.toDouble()),
                  ]
                ),
            ],
           ),

        ],
      ),
    );
  }
}
