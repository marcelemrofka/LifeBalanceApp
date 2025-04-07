import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PerfilUsuario extends StatefulWidget {
  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final _nomeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _objetivo1Controller = TextEditingController();
  final _emailController = TextEditingController();

  File? _imagemPerfil;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeController.text = prefs.getString('nome') ?? '';
      _pesoController.text = prefs.getString('peso') ?? '';
      _alturaController.text = prefs.getString('altura') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _objetivo1Controller.text = prefs.getString('objetivo') ?? '';
      final imagePath = prefs.getString('imagemPerfil');
      if (imagePath != null) {
        _imagemPerfil = File(imagePath);
      }
    });
  }

  Future<void> _salvarPerfil() async {
    final nome = _nomeController.text;
    final peso = _pesoController.text;
    final altura = _alturaController.text;
    final email = _emailController.text;
    final objetivo1 = _objetivo1Controller.text;

    if (nome.isEmpty || peso.isEmpty || altura.isEmpty || email.isEmpty || objetivo1.isEmpty || _imagemPerfil == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, preencha todos os campos e adicione uma foto!')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', nome);
    await prefs.setString('peso', peso);
    await prefs.setString('altura', altura);
    await prefs.setString('email', email);
    await prefs.setString('objetivo', objetivo1);
    await prefs.setString('imagemPerfil', _imagemPerfil!.path);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil salvo com sucesso!')));
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemPerfil = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: AppColors.lightText),), 
        centerTitle: true, 
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText,),onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _selecionarImagem,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imagemPerfil != null ? FileImage(_imagemPerfil!) : null,
                  child: _imagemPerfil == null
                      ? Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 60,
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pesoController,
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _alturaController,
              decoration: InputDecoration(
                labelText: 'Altura (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _objetivo1Controller,
              decoration: InputDecoration(
                labelText: 'Objetivo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _salvarPerfil,
                child: Text('Salvar Perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
