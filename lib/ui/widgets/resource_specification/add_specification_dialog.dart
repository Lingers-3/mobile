import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/data/models/resource_specifications/resource_type.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddSpecificationDialog extends StatefulWidget {
  final ItemType itemType;
  final int projectId;

  const AddSpecificationDialog({
    super.key,
    required this.itemType,
    required this.projectId,
  });

  @override
  State<AddSpecificationDialog> createState() => _AddSpecificationDialogState();
}

class _AddSpecificationDialogState extends State<AddSpecificationDialog> {
  final _quantityController = TextEditingController();
  ResourceType _selectedResourceType = ResourceType.consumable;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryBackground,
      title: Column(
        children: [
          const Text(
            'Resource settings',
            style: TextStyle(fontSize: 18, color: AppColors.purple),
          ),
          const SizedBox(height: 4),
          Text(
            widget.itemType.name,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.pink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Вибір типу ресурсу
          DropdownButtonFormField<ResourceType>(
            dropdownColor: AppColors.primaryBackground,
            initialValue: _selectedResourceType,
            decoration: const InputDecoration(
              labelText: 'Type of using',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: ResourceType.consumable,
                child: Row(
                  children: [
                    Icon(Icons.layers, size: 16, color: AppColors.cyan),
                    SizedBox(width: 8),
                    Text('Material', style: TextStyle(color: AppColors.purple)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: ResourceType.tool,
                child: Row(
                  children: [
                    Icon(Icons.handyman, size: 16, color: AppColors.pink),
                    SizedBox(width: 8),
                    Text('Tool', style: TextStyle(color: AppColors.purple)),
                  ],
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedResourceType = val);
            },
          ),
          const SizedBox(height: 16),

          // Введення кількості
          CustomTextField(
            controller: _quantityController,
            labelText:
                'Planned quantity (${widget.itemType.displayMeasurementUnit})',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Reject',
            style: TextStyle(color: AppColors.purple),
          ),
        ),
        GradientButton(label: 'Add', onPressed: _submit, width: 100),
      ],
    );
  }

  void _submit() {
    final plannedQuantity = double.tryParse(_quantityController.text);
    if (plannedQuantity == null || plannedQuantity < 0) {
      setState(() => _errorText = 'Planned quantity must be greater than 0');
      return;
    }
    final project = context.read<ProjectProvider>().getById(widget.projectId);
    if (project != null) {
      switch (project.state) {
        case ProjectState.planned:
          context.read<ProjectProvider>().planResource(
            project.id,
            widget.itemType.id,
            _selectedResourceType,
            plannedQuantity,
          );
          break;
        case ProjectState.inProgress:
          context.read<ProjectProvider>().addResourceSpecification(
            project.id,
            widget.itemType.id,
            _selectedResourceType,
            plannedQuantity,
          );
          break;
        default:
          throw UnimplementedError();
      }
    }

    Navigator.pop(context, true);
  }
}
