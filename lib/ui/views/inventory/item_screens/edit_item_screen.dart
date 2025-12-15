import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/items/item.dart';
import 'package:pocketeer_mobile/data/models/items/item_update_request.dart';
import 'package:pocketeer_mobile/data/services/item_service.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_date_input.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:pocketeer_mobile/ui/widgets/tag_selector.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ItemService();

  late TextEditingController _descriptionCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _priceCtrl;

  DateTime? _expirationDate;
  List<int> _selectedTags = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _descriptionCtrl = TextEditingController(
      text: widget.item.description ?? "",
    );
    _quantityCtrl = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _priceCtrl = TextEditingController(
      text: widget.item.purchasePrice?.toString() ?? "",
    );

    _expirationDate = widget.item.expirationDate;
    _selectedTags = [...widget.item.tagIds];
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final req = ItemUpdateRequest(
        description: _descriptionCtrl.text.trim(),
        quantity: double.tryParse(_quantityCtrl.text),
        purchasePrice: double.tryParse(_priceCtrl.text),
        expirationDate: _expirationDate,
        displayMeasurementUnit: widget.item.displayMeasurementUnit,
        tagIds: _selectedTags,
      );

      print('DEBUG: _expirationDate (State) = $_expirationDate');
      try {
        final jsonString = jsonEncode(req.toJson());
        print('DEBUG: ItemUpdateRequest (JSON) = $jsonString');
      } catch (e) {
        print('DEBUG: Could not JSON encode request: $e');
      }
      final updated = await _service.updateItem(widget.item.id, req);

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
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
          "Edit Item",
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
              children: [
                CustomTextField(
                  controller: _descriptionCtrl,
                  labelText: "Description",
                  hintText: "e.g. Fresh pack, optional",
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _quantityCtrl,
                  labelText: "Quantity (${widget.item.displayMeasurementUnit})",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return "Enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _priceCtrl,
                  labelText: "Purchase Price",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return "Enter a valid price";
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomDateInput(
                  selectedDate: _expirationDate,
                  label: "Expiration date",
                  onDateSelected: (date) {
                    setState(() {
                      _expirationDate = date;
                    });
                  },
                ),

                const SizedBox(height: 16),
                TagSelector(
                  selected: _selectedTags,
                  onChanged: (v) => setState(() => _selectedTags = v),
                ),

                const SizedBox(height: 32),

                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.fadePurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryBackground,
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
