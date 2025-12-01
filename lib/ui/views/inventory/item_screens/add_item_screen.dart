import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item_create_request.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_date_input.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class AddItemScreen extends StatefulWidget {
  final int itemTypeId;
  final String itemTypeName;
  final String baseUnit;
  final double? defaultQuantity;

  const AddItemScreen({
    super.key,
    required this.itemTypeId,
    required this.itemTypeName,
    required this.baseUnit,
    this.defaultQuantity,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _quantityController;
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.defaultQuantity?.toString() ?? "",
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final price = double.tryParse(_priceController.text);
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      final request = ItemCreateRequest(
        itemTypeId: widget.itemTypeId,
        description: description,
        quantity: quantity,
        expirationDate: _expirationDate,
        displayMeasurementUnit: widget.baseUnit,
        purchasePrice: price,
        tagIds: const [],
      );

      Navigator.pop(context, request);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: Text(
          'Додати айтем до "${widget.itemTypeName}"',
          style: const TextStyle(color: AppColors.pink, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextField(
                controller: _quantityController,
                labelText: 'Кількість (${widget.baseUnit})',
                hintText: 'Введіть кількість',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть кількість';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Введіть дійсне число більше нуля';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Опис (Необов\'язково)',
                hintText: 'Наприклад: "куплено в АТБ", "домашній"',
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              CustomDateInput(
                selectedDate: _expirationDate,
                label: 'Термін придатності',
                onDateSelected: (date) {
                  setState(() {
                    _expirationDate = date;
                  });
                },
              ),
              const SizedBox(height: 8.0),

              CustomTextField(
                controller: _priceController,
                labelText: 'Ціна купівлі (Необов\'язково)',
                hintText: 'Введіть ціну (наприклад 12.50)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Введіть дійсне число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Зберегти Айтем',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
