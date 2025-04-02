import 'package:flutter/material.dart';
import 'package:percent_indicator_premium/percent_indicator_premium.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Row(
        children: [
          Expanded(
            // https://pub.dev/packages/percentages_with_animation
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Carboidratos'),
                      Text('%Carboidratos'), 
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Proteina'),
                      Text('%Proteina'), 
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
             // https://pub.dev/packages/percentages_with_animation
            flex: 5,
            child: Center(
              child: Container(
                width: 160, 
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFF43644A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Gordura'),
                      Text('%Gordura'), 
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Fibras'),
                      Text('%Fibras'), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


