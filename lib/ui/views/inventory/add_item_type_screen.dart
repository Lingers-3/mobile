import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketeer_mobile/data/models/item_type_create_request.dart';
import 'package:pocketeer_mobile/data/services/picture_service.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/data/models/base_measurement_unit.dart';

class AddItemTypeScreen extends StatefulWidget {
  const AddItemTypeScreen({super.key});

  @override
  State<AddItemTypeScreen> createState() => _AddItemTypeScreenState();
}

class _AddItemTypeScreenState extends State<AddItemTypeScreen> {
  final _formKey = GlobalKey<FormState>();

  final PictureService _pictureService = PictureService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  BaseMeasurementUnit _selectedBaseUnit = BaseMeasurementUnit.piece;
  final _displayUnitController = TextEditingController();

  final _defaultQuantityController = TextEditingController(text: '0');
  final _shortageThresholdController = TextEditingController(text: '0');

  File? _imageFile;
  int? _uploadedPictureId;
  bool _uploadingPicture = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _displayUnitController.text = _selectedBaseUnit.label;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _displayUnitController.dispose();
    _defaultQuantityController.dispose();
    _shortageThresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) return;

      final file = File(picked.path);

      setState(() {
        _imageFile = file;
        _uploadingPicture = true;
      });

      final picId = await _pictureService.uploadPicture(file);

      setState(() {
        _uploadedPictureId = picId;
        _uploadingPicture = false;
      });
    } catch (e) {
      setState(() => _uploadingPicture = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка завантаження: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onBaseUnitChanged(BaseMeasurementUnit? newUnit) {
    if (newUnit == null) return;
    setState(() {
      _selectedBaseUnit = newUnit;
      _displayUnitController.text = newUnit.label;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final defaultQty = double.tryParse(_defaultQuantityController.text);
      final shortage = double.tryParse(_shortageThresholdController.text);

      final request = ItemTypeCreateRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        baseMeasurementUnit: _selectedBaseUnit.backendValue,
        displayMeasurementUnit: _selectedBaseUnit.backendValue,
        defaultQuantity: defaultQty,
        shortageThreshold: shortage,
        pictureId: _uploadedPictureId,
        tagIds: const [],
      );

      Navigator.of(context).pop(request);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка створення: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          'New Item Type',
          style: TextStyle(color: AppColors.purple),
        ),
        iconTheme: const IconThemeData(color: AppColors.purple),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// IMAGE PICKER

                /// NAME
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    labelStyle: TextStyle(color: AppColors.purple),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.purple),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.pink),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.pink),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введи назву' : null,
                ),
                const SizedBox(height: 16),

                /// DESCRIPTION
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.purple),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.purple),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.pink),
                    ),
                  ),
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.pink),
                ),
                const SizedBox(height: 24),

                /// UNITS
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BaseMeasurementUnit>(
                        initialValue: _selectedBaseUnit,
                        decoration: InputDecoration(
                          labelText: 'Base unit',
                          labelStyle: const TextStyle(color: AppColors.purple),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.purple),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pink),
                          ),
                        ),
                        dropdownColor: AppColors.primaryBackground,
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontSize: 16,
                        ),
                        items: BaseMeasurementUnit.values
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
                        onChanged: _onBaseUnitChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _displayUnitController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Display unit',
                          labelStyle: TextStyle(color: AppColors.purple),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.purple),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pink),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.pink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _defaultQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Default quantity',
                          labelStyle: TextStyle(color: AppColors.purple),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.purple),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pink),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.pink),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _shortageThresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Shortage threshold',
                          labelStyle: TextStyle(color: AppColors.purple),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.purple),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pink),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.pink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _uploadingPicture ? null : _pickImage,
                  child: Container(
                    height: 280,
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
                    child: _uploadingPicture
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.pink,
                            ),
                          )
                        : _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                color: AppColors.pink,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to add image",
                                style: TextStyle(color: AppColors.purple),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.fadePurple,
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: ElevatedButton(
                    onPressed: _loading || _uploadingPicture ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryBackground,
                          )
                        : const Text(
                            'Create',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
