import 'dart:io';
import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class TelaCadastroPaciente extends StatefulWidget {
  const TelaCadastroPaciente({super.key});

  @override
  State<TelaCadastroPaciente> createState() => _TelaCadastroPacienteState();
}

class _TelaCadastroPacienteState extends State<TelaCadastroPaciente> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _imageFile;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataNascimentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController objetivoController = TextEditingController();

  int? idade;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _calcularIdade(String dataStr) {
    try {
      DateTime nascimento = DateFormat('dd/MM/yyyy').parse(dataStr);
      DateTime hoje = DateTime.now();
      int anos = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        anos--;
      }
      setState(() => idade = anos);
    } catch (_) {
      idade = null;
    }
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? fotoUrl;

    if (_imageFile != null) {
      // Upload da imagem no Storage (caso tenha)

      // final storageRef = FirebaseStorage.instance
      //     .ref()
      //     .child('fotos_perfil/${user.uid}.jpg');
      // await storageRef.putFile(_imageFile!);
      // fotoUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'nome': nomeController.text.trim(),
      'data_nascimento': dataNascimentoController.text.trim(),
      'idade': idade,
      'email': emailController.text.trim(),
      'cpf': cpfController.text.trim(),
      'peso': double.tryParse(pesoController.text.trim()) ?? 0,
      'altura': double.tryParse(alturaController.text.trim()) ?? 0,
      'objetivo': objetivoController.text.trim(),
      'tp_user': false, // paciente
      'foto_url': fotoUrl,
      'nutricionista': user.uid, // vincula ao nutricionista logado
      'criado_em': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil salvo com sucesso!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.midText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Perfil do Paciente",
          style: TextStyle(color: AppColors.midText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(nomeController, "Nome completo"),
              _buildTextField(
                dataNascimentoController,
                "Data de nascimento (dd/mm/aaaa)",
                keyboardType: TextInputType.datetime,
                onChanged: _calcularIdade,
              ),
              if (idade != null)
                Text("Idade: $idade anos",
                    style: const TextStyle(fontSize: 14)),
              _buildTextField(emailController, "Email",
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(cpfController, "CPF"),
              _buildTextField(pesoController, "Peso (kg)",
                  keyboardType: TextInputType.number),
              _buildTextField(alturaController, "Altura (cm)",
                  keyboardType: TextInputType.number),
              _buildTextField(objetivoController, "Objetivo"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.laranja,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Salvar Perfil",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Preencha este campo';
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}
