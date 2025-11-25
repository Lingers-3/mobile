import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_type_update_request.dart';
import 'package:pocketeer_mobile/data/services/item_type_service.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/base_measurement_unit.dart';

class EditItemTypeScreen extends StatefulWidget {
  final ItemType itemType;

  const EditItemTypeScreen({super.key, required this.itemType});

  @override
  State<EditItemTypeScreen> createState() => _EditItemTypeScreenState();
}

class _EditItemTypeScreenState extends State<EditItemTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ItemTypeService();

  late TextEditingController name;
  late TextEditingController description;
  // removed baseUnit TextEditingController
  late TextEditingController displayUnit;
  late TextEditingController defaultQty;
  late TextEditingController shortage;

  // new: use enum for base unit
  late BaseMeasurementUnit _selectedBaseUnit;

  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.itemType.name);
    description = TextEditingController(
      text: widget.itemType.description ?? "",
    );

    // initialize selected base unit from backend value
    _selectedBaseUnit = BaseMeasurementUnit.fromBackend(
      widget.itemType.baseMeasurementUnit,
    );

    displayUnit = TextEditingController(
      text: BaseMeasurementUnit.fromBackend(
        widget.itemType.displayMeasurementUnit,
      ).label,
    );
    defaultQty = TextEditingController(
      text: widget.itemType.defaultQuantity?.toString() ?? "",
    );
    shortage = TextEditingController(
      text: widget.itemType.shortageThreshold?.toString() ?? "",
    );

    void listener() => _checkChanges();
    name.addListener(listener);
    description.addListener(listener);
    defaultQty.addListener(listener);
    shortage.addListener(listener);
  }

  void _onBaseUnitChanged(BaseMeasurementUnit? newUnit) {
    if (newUnit == null) return;
    setState(() {
      _selectedBaseUnit = newUnit;
      // display follows base unit (readonly)
      displayUnit.text = newUnit.label;
    });
    _checkChanges();
  }

  void _checkChanges() {
    final changed =
        name.text.trim() != widget.itemType.name ||
        description.text.trim() != (widget.itemType.description ?? "") ||
        // compare backend values for units
        _selectedBaseUnit.backendValue != widget.itemType.baseMeasurementUnit ||
        _selectedBaseUnit.backendValue !=
            widget.itemType.displayMeasurementUnit ||
        defaultQty.text.trim() !=
            (widget.itemType.defaultQuantity?.toString() ?? "") ||
        shortage.text.trim() !=
            (widget.itemType.shortageThreshold?.toString() ?? "");

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _save() async {
    if (!_hasChanges) return;

    setState(() => _saving = true);

    final req = ItemTypeUpdateRequest(
      name: name.text.trim(),
      description: description.text.trim().isEmpty
          ? null
          : description.text.trim(),
      // send backendValue
      baseMeasurementUnit: _selectedBaseUnit.backendValue,
      displayMeasurementUnit: _selectedBaseUnit.backendValue,
      defaultQuantity: double.tryParse(defaultQty.text.trim()),
      shortageThreshold: double.tryParse(shortage.text.trim()),
    );

    try {
      final updated = await _service.updateItemType(widget.itemType.id, req);

      Provider.of<ItemTypeProvider>(
        context,
        listen: false,
      ).replaceItem(updated);

      Navigator.pop(context, updated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    displayUnit.dispose();
    defaultQty.dispose();
    shortage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          "Edit ${widget.itemType.name}",
          style: const TextStyle(color: AppColors.purple),
        ),
        backgroundColor: AppColors.primaryBackground,
        iconTheme: const IconThemeData(color: AppColors.purple),
        actions: [
          TextButton(
            onPressed: _hasChanges && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "Save",
                    style: TextStyle(
                      color: _hasChanges ? AppColors.pink : AppColors.cyan,
                      fontSize: 18,
                    ),
                  ),
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _field("Name", name),
            _field("Description", description),
            // replace base/display text fields with dropdown + readonly display
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<BaseMeasurementUnit>(
                      initialValue: _selectedBaseUnit,
                      decoration: const InputDecoration(
                        labelText: 'Base unit',
                        labelStyle: TextStyle(color: AppColors.purple),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.pink),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.purple),
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
                      controller: displayUnit,
                      readOnly: true,
                      style: const TextStyle(color: AppColors.pink),
                      decoration: const InputDecoration(
                        labelText: 'Display unit',
                        labelStyle: TextStyle(color: AppColors.purple),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.pink),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.purple),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _field("Default qty", defaultQty, type: TextInputType.number),
            _field("Shortage threshold", shortage, type: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: AppColors.pink),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.purple),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.pink),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.purple),
          ),
        ),
      ),
    );
  }
}
