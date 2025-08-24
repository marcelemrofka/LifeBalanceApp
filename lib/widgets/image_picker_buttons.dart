import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButtons extends StatelessWidget {
  final void Function(File imagem) onImageSelected;

  const ImagePickerButtons({super.key, required this.onImageSelected});

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera, context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tirar Foto'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery, context),
          icon: const Icon(Icons.photo),
          label: const Text('Galeria'),
        ),
      ],
    );
  }
}
