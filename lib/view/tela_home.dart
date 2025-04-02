import 'package:app/widgets/carrossel.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaHome(),
    );
  }
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center (
       child: Column(
        children: [
          const SizedBox(height: 45),
          const Dashboard(),
          const SizedBox(height: 10),
          const Carrossel(), 
        ],
      ),
    ),
    );
  }
}