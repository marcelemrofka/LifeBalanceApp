import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:AppColors.principal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context,icon: Icons.restaurant, label: 'Refeição',route: '/tela_refeicao',),
          _verticalDivider(),
          _navItem(context,icon: Icons.history,label: 'Histórico',route: '/tela_historico',),
          _verticalDivider(),
          _navItem( context, icon: Icons.info_outline, label: 'Sobre', route: '/tela_sobre',
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white38,
    );
  }
}
