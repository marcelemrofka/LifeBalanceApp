import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF43644A),
      child: ListView(
        children: [
          DrawerHeader(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                Image.asset('../lib/images/logo-folha.png', width: 35, height: 35),
                SizedBox(width: 10),
                Text('Menu', style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
            )
          ),
          )
        ],
      ),
    );
  }
}