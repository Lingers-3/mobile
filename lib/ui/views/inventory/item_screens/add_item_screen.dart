import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item_create_request.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_date_input.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:pocketeer_mobile/ui/widgets/tag_selector.dart';

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
  List<int> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.defaultQuantity?.toString() ?? "",
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text);
    final description =
        _descriptionController.text.isEmpty ? null : _descriptionController.text;

    final request = ItemCreateRequest(
      itemTypeId: widget.itemTypeId,
      description: description,
      quantity: quantity,
      expirationDate: _expirationDate,
      displayMeasurementUnit: widget.baseUnit,
      purchasePrice: price,
      tagIds: _selectedTags,
    );

    Navigator.pop(context, request);
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
          'Add item for "${widget.itemTypeName}"',
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
                labelText: 'Quantity (${widget.baseUnit})',
                hintText: 'Enter quantity',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter quantity';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Quantity must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (optional)',
                hintText: 'e.g. Fresh pack, side shelf',
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              CustomDateInput(
                selectedDate: _expirationDate,
                label: 'Expiration date',
                onDateSelected: (date) {
                  setState(() {
                    _expirationDate = date;
                  });
                },
              ),
              const SizedBox(height: 8.0),

              CustomTextField(
                controller: _priceController,
                labelText: 'Purchase price (optional)',
                hintText: 'e.g. 12.50',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TagSelector(
                selected: _selectedTags,
                onChanged: (v) => setState(() => _selectedTags = v),
              ),
              const SizedBox(height: 32.0),

              GradientButton(
                label: 'Create item',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
