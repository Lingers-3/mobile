import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pocketeer_mobile/data/models/unit.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type_update_request.dart';
import 'package:pocketeer_mobile/data/services/item_type_service.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/tag_selector.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class EditItemTypeScreen extends StatefulWidget {
  final ItemType itemType;
  const EditItemTypeScreen({super.key, required this.itemType});

  @override
  State<EditItemTypeScreen> createState() => _EditItemTypeScreenState();
}

class _EditItemTypeScreenState extends State<EditItemTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ItemTypeService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _defaultQtyCtrl;
  late final TextEditingController _shortageCtrl;

  late Unit _baseUnit;
  late Unit _displayUnit;
  late List<int> _selectedTags;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.itemType.name);
    _descCtrl = TextEditingController(text: widget.itemType.description ?? "");
    _defaultQtyCtrl = TextEditingController(
      text: widget.itemType.defaultQuantity?.toString() ?? "0",
    );
    _shortageCtrl = TextEditingController(
      text: widget.itemType.shortageThreshold?.toString() ?? "0",
    );

    _baseUnit = findUnit(widget.itemType.baseMeasurementUnit);
    _displayUnit = findUnit(widget.itemType.displayMeasurementUnit);

    _baseUnit = _ensureInList(_baseUnit, allUnits);
    _displayUnit = _ensureInList(
      _displayUnit,
      unitsOfCategory(_baseUnit.category),
    );

    _selectedTags = [...widget.itemType.tagIds];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _defaultQtyCtrl.dispose();
    _shortageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final req = ItemTypeUpdateRequest(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      baseMeasurementUnit: _baseUnit.backendValue,
      displayMeasurementUnit: _displayUnit.backendValue,
      defaultQuantity: double.tryParse(_defaultQtyCtrl.text),
      shortageThreshold: double.tryParse(_shortageCtrl.text),
      tagIds: _selectedTags,
    );

    final updated = await _service.updateItemType(widget.itemType.id, req);

    context.read<ItemTypeProvider>().replaceItem(updated);
    context.read<ItemProvider>().updateItemsUnitForType(
      widget.itemType.id,
      updated.baseMeasurementUnit,
    );

    if (mounted) Navigator.pop(context, updated);

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final compatibleDisplayUnits = unitsOfCategory(_baseUnit.category);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.purple),
        backgroundColor: AppColors.primaryBackground,
        title: Text(
          "Edit ${widget.itemType.name}",
          style: const TextStyle(color: AppColors.purple),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(
                "Name",
                _nameCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  return null;
                },
              ),

              _field("Description", _descCtrl),

              const SizedBox(height: 16),

              DropdownButtonFormField<Unit>(
                initialValue: _baseUnit,
                items: allUnits
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(
                          "${u.label} (${u.backendValue})",
                          style: const TextStyle(color: AppColors.pink),
                        ),
                      ),
                    )
                    .toList(),
                dropdownColor: AppColors.primaryBackground,
                decoration: const InputDecoration(
                  labelText: "Base unit",
                  labelStyle: TextStyle(color: AppColors.purple),
                ),
                onChanged: (u) {
                  if (u == null) return;
                  setState(() {
                    _baseUnit = u;
                    _displayUnit = u; // reset display to match base
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Unit>(
                initialValue: _displayUnit,
                items: compatibleDisplayUnits
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(
                          "${u.label} (${u.backendValue})",
                          style: const TextStyle(color: AppColors.pink),
                        ),
                      ),
                    )
                    .toList(),
                dropdownColor: AppColors.primaryBackground,
                decoration: const InputDecoration(
                  labelText: "Display unit",
                  labelStyle: TextStyle(color: AppColors.purple),
                ),
                onChanged: (u) {
                  if (u != null) setState(() => _displayUnit = u);
                },
              ),

              const SizedBox(height: 16),

              _field(
                "Default quantity",
                _defaultQtyCtrl,
                type: TextInputType.number,
              ),
              _field(
                "Shortage threshold",
                _shortageCtrl,
                type: TextInputType.number,
              ),

              const SizedBox(height: 16),
              TagSelector(
                selected: _selectedTags,
                onChanged: (v) => setState(() => _selectedTags = v),
              ),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.fadePurple,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
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
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
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

  Unit _ensureInList(Unit unit, List<Unit> list) {
    return list.firstWhere(
      (u) => u.backendValue == unit.backendValue,
      orElse: () => list.first,
    );
  }
}
