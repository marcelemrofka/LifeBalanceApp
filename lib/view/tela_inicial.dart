import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import '../widgets/popup_login.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.principal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/images/logo.png', width: 300, height: 300),
            SizedBox(height: 70),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  _mostrarPopupLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Entrar'),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/tela_cadastro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Cadastre-se'),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/planos');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('PLANOS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarPopupLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PopupLogin();
      },
    );
  }
}
