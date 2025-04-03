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
  
  Widget progressBar(String label, double value, double maxValue) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: LinearPercentage(
            currentPercentage: (value / maxValue) * 100,
            maxPercentage: 100,
            backgroundHeight: 10,
            percentageHeight: 10,
            leftRightText: LeftRightText.none, // textos laterais
            backgroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300,
            ),
            percentageDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(0)}g',
            style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final nutrition = Provider.of<NutritionViewModel>(context).nutrition;
     
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Carb e Fibras
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                progressBar("Carboidratos", nutrition.carboPercentual, 100),
                progressBar("Fibras", nutrition.fibraPercentual, 100),
            ],
          ),
            
          // Circulo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160, 
                decoration: const BoxDecoration(color: Color(0xFF43644A), shape: BoxShape.circle,),
              ),

              // porcentagem ao redor
              CircularPercentage(
                  currentPercentage: nutrition.caloriasPercentual, 
                  maxPercentage: 100, 
                  size: 160,
                  percentageStrokeWidth: 7, 
                  backgroundStrokeWidth: 1,
                  percentageColor: Colors.green.shade400,
                  centerText: '', // precisa ser vazio para ser sobreposto
                ),

                // Textos dentro do circulo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${nutrition.caloriasIngeridas.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    ),
                    const Text("Consumidas", style: TextStyle(fontSize: 10, color: Colors.white)),
                    SizedBox(height: 15),
                    Text(
                      "Você consumiu ${nutrition.caloriasPercentual.toStringAsFixed(0)}%",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
            ],
                
    
              // ],
            // ),
          ),
           
          // Proteinas e Gorduras 
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              progressBar("Proteínas", nutrition.proteinaPercentual, 100),
              progressBar("Gorduras", nutrition.gorduraPercentual, 100)
            ],
          ),
          
        ],
      ),
    );
  }
}
