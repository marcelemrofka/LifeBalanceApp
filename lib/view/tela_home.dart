import 'package:app/widgets/carrossel.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/drawer.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Center (
       child: Column(
        children: [
          const SizedBox(height: 45),
          const Menu(),
          const Dashboard(),
          const SizedBox(height: 10),
          const Carrossel(), 
        ],
      ),
    ),
    );
  }
}
