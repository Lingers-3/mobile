import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type_create_request.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/ui/widgets/tag_selector.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:provider/provider.dart';

class AddItemTypeScreen extends StatefulWidget {
  const AddItemTypeScreen({super.key});

  @override
  State<AddItemTypeScreen> createState() => _AddItemTypeScreenState();
}

class _AddItemTypeScreenState extends State<AddItemTypeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _shortage = TextEditingController(text: "0");
  final _defaultQty = TextEditingController(text: "1");

  Unit _selectedUnit = allUnits.first;

  File? _imageFile;
  int? _pictureId;
  bool _uploading = false;

  List<int> _selectedTags = [];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _shortage.dispose();
    _defaultQty.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      _imageFile = File(file.path);
      _uploading = true;
    });

    try {
      final picture = await context.read<PictureProvider>().uploadPicture(
        _imageFile!,
      );
      setState(() => _pictureId = picture.id);
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final req = ItemTypeCreateRequest(
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      baseMeasurementUnit: _selectedUnit.backendValue,
      displayMeasurementUnit: _selectedUnit.backendValue,
      defaultQuantity: double.tryParse(_defaultQty.text),
      shortageThreshold: double.tryParse(_shortage.text),
      pictureId: _pictureId,
      tagIds: _selectedTags,
    );

    Navigator.pop(context, req);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.purple),
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          "New Item Type",
          style: TextStyle(color: AppColors.purple),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Enter name" : null,
                  decoration: _input("Name *"),
                  style: const TextStyle(color: AppColors.pink),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  decoration: _input("Description"),
                  style: const TextStyle(color: AppColors.pink),
                ),

                const SizedBox(height: 24),

                TagSelector(
                  selected: _selectedTags,
                  onChanged: (v) => _selectedTags = v,
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<Unit>(
                  initialValue: _selectedUnit,
                  decoration: _input("Measurement unit"),
                  items: allUnits
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(
                            u.label,
                            style: const TextStyle(color: AppColors.pink),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (u) => setState(() => _selectedUnit = u!),
                  dropdownColor: AppColors.primaryBackground,
                  style: const TextStyle(color: AppColors.pink),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _defaultQty,
                  keyboardType: TextInputType.number,
                  decoration: _input("Default quantity"),
                  style: const TextStyle(color: AppColors.pink),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _shortage,
                  keyboardType: TextInputType.number,
                  decoration: _input("Shortage threshold"),
                  style: const TextStyle(color: AppColors.pink),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _uploading ? null : _pickImage,
                  child: Container(
                    height: 400,
                    width: 400,
                    decoration: BoxDecoration(
                      color: AppColors.dialogBackground,
                      borderRadius: BorderRadius.circular(12),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _uploading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.pink,
                            ),
                          )
                        : _imageFile == null
                        ? const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: AppColors.pink,
                              size: 50,
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 32),

                GradientButton(
                  label: "Create",
                  onPressed: _submit,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.purple),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.purple),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.pink),
    ),
  );
}
