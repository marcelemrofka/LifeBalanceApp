import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/color.dart'; // Certifique-se que AppColors.laranja existe

class ImagePickerButtons extends StatelessWidget {
  final void Function(File imagem) onImageSelected;

  const ImagePickerButtons({super.key, required this.onImageSelected});

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 16), 
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Adicione uma imagem da sua refeição",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18, // 👈 um pouco menor
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161), // 
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Você pode tirar uma foto ou escolher da galeria",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey,
            height: 1.4,
          ),
        ),

          const SizedBox(height: 45),

          // Imagem ilustrativa
          Image.asset(
            'lib/images/refeicao.png',
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
            },
          ),

          const SizedBox(height: 60),

          // Botões menores e arredondados
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoundedButton(
                label: "Câmera",
                icon: Icons.camera_alt_outlined,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 20),
              _buildRoundedButton(
                label: "Galeria",
                icon: Icons.photo_library_outlined,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.laranja, AppColors.laranja.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
