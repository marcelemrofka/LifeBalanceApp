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
          .buscarMetasDoPaciente();
    });
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

// import 'dart:math';
// import 'package:app/utils/color.dart';
// import 'package:app/viewmodel/nutrition_vm.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:percentages_with_animation/percentages_with_animation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   Stream<DocumentSnapshot<Map<String, dynamic>>>? _historicoStream;

//   @override
//   void initState() {
//     super.initState();

//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid != null) {
//       final hoje = DateTime.now();
//       final dataFormatada =
//           "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
//       final docId = "${uid}_$dataFormatada";

//       _historicoStream = FirebaseFirestore.instance
//           .collection('historico')
//           .doc(docId)
//           .snapshots();
//     }

//     // Carrega metas salvas no Firestore via ViewModel
//     Future.microtask(() {
//       Provider.of<NutritionViewModel>(context, listen: false)
//           .buscarMetasDoPaciente();
//     });
//   }

//   Widget progressBar(String label, double gramas, double maxGramas, double width) {
//     double porcentagem =
//         (maxGramas > 0 && gramas >= 0) ? min(100, (gramas / maxGramas) * 100) : 0;

//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 15,
//               color: AppColors.midText,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         const SizedBox(height: 3),
//         SizedBox(
//           width: width,
//           child: LinearPercentage(
//             currentPercentage: porcentagem,
//             maxPercentage: 100,
//             backgroundHeight: 8,
//             percentageHeight: 8,
//             leftRightText: LeftRightText.none,
//             backgroundDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(6),
//               color: Colors.grey.shade200,
//             ),
//             percentageDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(6),
//               color: AppColors.verdeGrafico,
//             ),
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           '${gramas.toStringAsFixed(0)}g',
//           style: const TextStyle(fontSize: 12, color: AppColors.midText),
//         ),
//       ],
//     );
//   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final nutrition = Provider.of<NutritionViewModel>(context);

// //     if (nutrition.carregando) {
// //       return const Center(
// //         child: CircularProgressIndicator(color: AppColors.principal),
// //       );
// //     }

// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final circleSize = screenWidth * 0.35;
// //     final barWidth = screenWidth * 0.28;
// //     final horizontalPadding = screenWidth * 0.02;

// //     return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
// //       stream: _historicoStream,
// //       builder: (context, snapshot) {
// //         if (snapshot.hasData && snapshot.data!.exists) {
// //           final data = snapshot.data!.data()!;
// //           nutrition.caloriasIngeridas = (data['total_calorias'] ?? 0).toDouble();
// //           nutrition.carboIngerido = (data['total_carboidrato'] ?? 0).toDouble();
// //           nutrition.proteinaIngerida = (data['total_proteina'] ?? 0).toDouble();
// //           nutrition.gorduraIngerida = (data['total_gordura'] ?? 0).toDouble();
// //           nutrition.fibraIngerida = (data['total_fibra'] ?? 0).toDouble();
// //           nutrition.aguaConsumida = (data['total_agua'] ?? data['agua'] ?? 0).toDouble();
// //         }

// //         return Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   // Esquerda (Carboidratos e Fibras)
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       progressBar(
// //                         "Carboidratos",
// //                         nutrition.carboIngerido,
// //                         nutrition.carboRecomendado,
// //                         barWidth,
// //                       ),
// //                       SizedBox(height: circleSize * 0.09),
// //                       progressBar(
// //                         "Fibras",
// //                         nutrition.fibraIngerida,
// //                         nutrition.fibraRecomendada,
// //                         barWidth,
// //                       ),
// //                     ],
// //                   ),

// //                   // Círculo principal (verde escuro)
// //                   Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       // Fundo verde escuro
// //                       Container(
// //                         width: circleSize,
// //                         height: circleSize,
// //                         decoration: const BoxDecoration(
// //                           color: AppColors.principal,
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),

// //                       // Borda animada
// //                       CircularPercentage(
// //                         currentPercentage: min(100, nutrition.caloriasPercentual),
// //                         maxPercentage: 100,
// //                         size: circleSize,
// //                         percentageStrokeWidth: circleSize * 0.035,
// //                         backgroundStrokeWidth: 1,
// //                         backgroundColor: Colors.transparent,
// //                         percentageColor: AppColors.verdeGrafico,
// //                         centerText: '',
// //                       ),

// //                       // Conteúdo interno
// //                       Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Text(
// //                             '${nutrition.caloriasIngeridas.toStringAsFixed(0)} kcal',
// //                             style: const TextStyle(
// //                               fontSize: 21,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                           SizedBox(height: circleSize * 0.03),
// //                           Text(
// //                             "Consumidas",
// //                             style: TextStyle(
// //                               fontSize: circleSize * 0.08,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                           SizedBox(height: circleSize * 0.06),
// //                           Text(
// //                             "Você já atingiu ${nutrition.caloriasPercentual.toStringAsFixed(0)}%",
// //                             style: TextStyle(
// //                               fontSize: circleSize * 0.07,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),

// //                   // Direita (Proteínas e Gorduras)
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       progressBar(
// //                         "Proteínas",
// //                         nutrition.proteinaIngerida,
// //                         nutrition.proteinaRecomendada,
// //                         barWidth,
// //                       ),
// //                       SizedBox(height: circleSize * 0.09),
// //                       progressBar(
// //                         "Gorduras",
// //                         nutrition.gorduraIngerida,
// //                         nutrition.gorduraRecomendada,
// //                         barWidth,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             SizedBox(height: screenWidth * 0.05),

// //             // RichText abaixo dos gráficos
// //             RichText(
// //               text: TextSpan(
// //                 style: TextStyle(
// //                   fontSize: screenWidth * 0.032,
// //                   color: AppColors.midText,
// //                 ),
// //                 children: [
// //                   const TextSpan(text: 'Sua meta de calorias diárias é: '),
// //                   TextSpan(
// //                     text:
// //                         '${nutrition.caloriasRecomendadas.toStringAsFixed(0)} kcal',
// //                     style: TextStyle(
// //                       fontSize: screenWidth * 0.032,
// //                       fontWeight: FontWeight.bold,
// //                       color: AppColors.principal,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // }

