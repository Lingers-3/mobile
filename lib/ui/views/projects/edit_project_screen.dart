import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  // Планування
  late TextEditingController _plannedIncomeController;
  late TextEditingController _plannedHoursController;
  DateTime? _plannedDeadline;

  // Фактичні
  late TextEditingController _actualIncomeController;
  late TextEditingController _actualHoursController;
  DateTime? _actualDeadline;

  late ProjectStatus _status;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _status = p.status;

    _nameController = TextEditingController(text: p.name);
    _descController = TextEditingController(text: p.description);

    _plannedIncomeController = TextEditingController(
      text: p.plannedIncome?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '',
    );
    _plannedHoursController = TextEditingController(
      text: p.plannedHours?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '',
    );
    _plannedDeadline = p.plannedDeadline;

    _actualIncomeController = TextEditingController(
      text: p.actualIncome.toString().replaceAll(RegExp(r'\.0$'), ''),
    );
    _actualHoursController = TextEditingController(
      text: p.actualHours.toString().replaceAll(RegExp(r'\.0$'), ''),
    );
    _actualDeadline = p.actualDeadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _plannedIncomeController.dispose();
    _plannedHoursController.dispose();
    _actualIncomeController.dispose();
    _actualHoursController.dispose();
    super.dispose();
  }

  // --- ЛОГІКА ДОСТУПУ ДО ПОЛІВ ---
  bool get _isPlanningEditable => _status == ProjectStatus.planned;
  bool get _isActualEditable => _status != ProjectStatus.planned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагування проекту'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProject),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- ЗАГАЛЬНІ ---
            _buildSectionHeader('Основна інформація'),
            CustomTextField(
              controller: _nameController,
              labelText: 'Назва проекту',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descController,
              labelText: 'Опис',
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Статус
            DropdownButtonFormField<ProjectStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              items: ProjectStatus.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.label));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _status = val);
                }
              },
            ),

            const SizedBox(height: 24),

            // --- ПЛАНУВАННЯ ---
            _buildSectionHeader(
              'Планування',
              isActive: _isPlanningEditable,
              note: _isPlanningEditable
                  ? null
                  : '(Тільки для статусу "Заплановано")',
            ),

            _buildDatePicker(
              label: 'Запланований дедлайн',
              selectedDate: _plannedDeadline,
              enabled: _isPlanningEditable,
              onDateSelected: (date) => setState(() => _plannedDeadline = date),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _plannedIncomeController,
                    label: 'План. дохід',
                    enabled: _isPlanningEditable,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    controller: _plannedHoursController,
                    label: 'План. години',
                    enabled: _isPlanningEditable,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ФАКТИЧНІ ---
            _buildSectionHeader(
              'Фактичні дані',
              isActive: _isActualEditable,
              note: _isActualEditable ? null : '(Недоступно в "Заплановано")',
            ),

            _buildDatePicker(
              label: 'Фактичний термін',
              selectedDate: _actualDeadline,
              enabled: _isActualEditable,
              onDateSelected: (date) => setState(() => _actualDeadline = date),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _actualIncomeController,
                    label: 'Факт. дохід',
                    enabled: _isActualEditable,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    controller: _actualHoursController,
                    label: 'Факт. години',
                    enabled: _isActualEditable,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool isActive = true,
    String? note,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black87 : Colors.grey,
            ),
          ),
          if (note != null)
            Text(
              note,
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  // Обгортка для CustomTextField або стандартного поля з логікою enabled
  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: CustomTextField(
          controller: controller,
          labelText: label,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required bool enabled,
    required Function(DateTime) onDateSelected,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              selectedDate != null
                  ? '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}'
                  : 'Оберіть дату',
              style: TextStyle(
                color: selectedDate != null
                    ? Colors.black87
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final updatedProject = Project(
        id: widget.project.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        status: _status,

        createdAt: widget.project.createdAt,
        updatedAt: DateTime.now(), // Оновлюємо дату зміни
        startDate: widget.project.startDate,
        endDate: widget.project.endDate,
        currency: widget.project.currency,

        // ЛОГІКА ПЛАНУВАННЯ
        // Якщо можна редагувати - беремо з форми. Якщо ні - залишаємо старе.
        plannedDeadline: _isPlanningEditable
            ? _plannedDeadline
            : widget.project.plannedDeadline,
        plannedIncome: _isPlanningEditable
            ? double.tryParse(_plannedIncomeController.text)
            : widget.project.plannedIncome,
        plannedHours: _isPlanningEditable
            ? double.tryParse(_plannedHoursController.text)
            : widget.project.plannedHours,

        // ЛОГІКА ФАКТИЧНИХ
        actualDeadline: _isActualEditable
            ? _actualDeadline
            : widget.project.actualDeadline,
        actualIncome: _isActualEditable
            ? double.tryParse(_actualIncomeController.text)
            : widget.project.actualIncome,
        actualHours: _isActualEditable
            ? double.tryParse(_actualHoursController.text)
            : widget.project.actualHours,
      );

      context.read<ProjectProvider>().updateProject(updatedProject);
      Navigator.pop(context);
    }
  }
}
