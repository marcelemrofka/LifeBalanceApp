import 'package:flutter/material.dart';
import 'package:percentages_with_animation/percentages_with_animation.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final double carboidrato = 40;
  final double proteina = 30;
  final double gordura = 20;
  final double fibra = 30;
  final int calorias = 1550;
  final double percentCaloriasConsumidas = (0.72 * 100);

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
                progressBar("Carboidratos", carboidrato, 100),
                progressBar("Fibras", fibra, 100),
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
              
              CircularPercentage(
                  currentPercentage: percentCaloriasConsumidas, 
                  maxPercentage: 100, 
                  size: 160,
                  percentageStrokeWidth: 7, 
                  backgroundStrokeWidth: 1,
                  percentageColor: Colors.green.shade400,
                  centerText: '', // precisa ser vazio para ser sobreposto
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${calorias.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    ),
                    const Text("Consumidas", style: TextStyle(fontSize: 10, color: Colors.white)),
                    SizedBox(height: 15),
                    Text(
                      "Você consumiu ${percentCaloriasConsumidas.toStringAsFixed(0)}%",
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
              progressBar("Proteínas", proteina, 100),
              progressBar("Gorduras", gordura, 100)
            ],
          ),
          
        ],
      ),
    );
  }
}
