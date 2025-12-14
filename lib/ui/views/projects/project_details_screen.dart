import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';
import 'package:pocketeer_mobile/providers/resource_specification_provider.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/ui/views/projects/resource_specification_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects/select_resource_item_type_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects/edit_project_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_specification/resource_specification_card.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    // Завантажуємо дані, необхідні для деталізації
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemTypeProvider>().loadItemTypes();
      context.read<ItemProvider>().loadAllItems();
      context.read<ResourceReservationProvider>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>().projects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );

    // Фільтруємо специфікації, які належать саме цьому проекту
    final allSpecs = context
        .watch<ResourceSpecificationProvider>()
        .specifications;
    final projectSpecs = allSpecs
        .where((s) => s.projectId == project.id)
        .toList();
    final projectItemTypes = context.select<ItemTypeProvider, List<ItemType>>(
      (p) => p.itemTypes
          .where((it) => projectSpecs.any((rs) => rs.itemTypeId == it.id))
          .toList(),
    );

    final dateInfo = _getProjectDateInfo(project);

    final desc = project.description;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.purple),
        backgroundColor: AppColors.primaryBackground,
        title: Text(project.name, style: TextStyle(color: AppColors.purple)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.purple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'project_details_fab_${project.id}',
        backgroundColor: AppColors.pink, // Унікальний тег
        onPressed: () {
          final usedTypeIds = projectSpecs.map((s) => s.itemTypeId).toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectResourceItemTypeScreen(
                excludedItemTypeIds: usedTypeIds,
                projectId: project.id,
              ),
            ),
          );
        },
        label: const Text('Add resource'),
        icon: const Icon(Icons.add),
      ),
      body: Container(
        color: AppColors.primaryBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Container(
            color: AppColors.primaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                project.state,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(project.state),
                              ),
                            ),
                            child: Text(
                              project.state.label,
                              style: TextStyle(
                                color: _getStatusColor(project.state),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (dateInfo != null)
                            Text(
                              dateInfo,
                              style: TextStyle(
                                color: AppColors.purple,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (desc != null && desc.isNotEmpty) ...[
                        InkWell(
                          onTap: () => setState(
                            () => _isDescriptionExpanded =
                                !_isDescriptionExpanded,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                desc,
                                maxLines: _isDescriptionExpanded ? null : 2,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: AppColors.purple,
                                ),
                              ),
                              if (!_isDescriptionExpanded && desc.length > 100)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Open...',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ] else
                        const Text(
                          "No description",
                          style: TextStyle(
                            color: AppColors.purple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- ДЗЕРКАЛЬНІ КОЛОНКИ ---
                Container(
                  color: AppColors.primaryBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PLANNED',
                                  style: TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.purple,
                                  ),
                                  onPressed:
                                      project.state != ProjectState.planned
                                      ? null
                                      : () {
                                          _showEditDialog(
                                            title: 'Edit planned',
                                            initialDate:
                                                project.plannedDeadline,
                                            initialIncome:
                                                project.plannedIncome,
                                            initialHours: project.plannedHours,
                                            currency: project.currency,
                                            onSave: (date, income, hours) {
                                              context
                                                  .read<ProjectProvider>()
                                                  .updateProject(
                                                    project.copyWith(
                                                      plannedDeadline: date,
                                                      plannedIncome: income,
                                                      plannedHours: hours,
                                                    ),
                                                  );
                                            },
                                          );
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildReadOnlyField(
                              label: 'Deadline',
                              value:
                                  _formatDate(project.plannedDeadline) ?? '—',
                            ),
                            _buildReadOnlyField(
                              label: 'Revenue',
                              value:
                                  project.plannedIncome != null &&
                                      project.plannedIncome != 0.0
                                  ? '${project.plannedIncome} ${project.currency}'
                                  : '—',
                            ),
                            _buildReadOnlyField(
                              label: 'Completion time',
                              value:
                                  project.plannedHours != null &&
                                      project.plannedHours != 0.0
                                  ? '${project.plannedHours} год'
                                  : '—',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 160,
                        color: AppColors.primaryBackground,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'IN FACT',
                                  style: TextStyle(
                                    color: AppColors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.purple,
                                  ),
                                  onPressed:
                                      project.state != ProjectState.inProgress
                                      ? null
                                      : () {
                                          _showEditDialog(
                                            title: 'Edit in Fact',
                                            initialDate: project.actualDeadline,
                                            initialIncome: project.actualIncome,
                                            initialHours: project.actualHours,
                                            currency: project.currency,
                                            onSave: (date, income, hours) {
                                              context
                                                  .read<ProjectProvider>()
                                                  .updateProject(
                                                    project.copyWith(
                                                      actualDeadline: date,
                                                      actualIncome: income,
                                                      actualHours: hours,
                                                    ),
                                                  );
                                            },
                                          );
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildReadOnlyField(
                              label: 'Deadline',
                              value: _formatDate(project.actualDeadline) ?? '—',
                              isBold: true,
                            ),
                            _buildReadOnlyField(
                              label: 'Revenue',
                              value:
                                  project.actualIncome != null &&
                                      project.actualIncome != 0
                                  ? '${project.actualIncome} ${project.currency}'
                                  : '—',
                              valueColor: (project.actualIncome ?? 0) > 0
                                  ? Colors.green
                                  : null,
                            ),
                            _buildReadOnlyField(
                              label: 'Completion time',
                              value:
                                  project.actualHours != null &&
                                      project.actualHours != 0.0
                                  ? '${project.actualHours} год'
                                  : '—',
                              valueColor:
                                  (project.plannedHours != null &&
                                      (project.actualHours ?? 0) >
                                          (project.plannedHours ?? 0))
                                  ? Colors.red
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- ЕКШЕНИ ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: project.state == ProjectState.planned
                            ? () => context
                                  .read<ProjectProvider>()
                                  .startProject(project.id)
                            : null,
                        child: const Text(
                          'Begin',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: project.state == ProjectState.inProgress
                            ? () => context
                                  .read<ProjectProvider>()
                                  .finishProject(project.id)
                            : null,
                        child: const Text(
                          'End',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: project.state == ProjectState.inProgress
                            ? () => context
                                  .read<ProjectProvider>()
                                  .cancelProject(project.id)
                            : null,
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- РЕСУРСИ ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'PROJECT RESOURCES',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                if (projectSpecs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Resources not added yet')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectSpecs.length,
                    itemBuilder: (context, index) {
                      final specification = projectSpecs[index];
                      final itemType = projectItemTypes.firstWhere(
                        (it) => it.id == specification.itemTypeId,
                      );
                      return ResourceSpecificationCard(
                        specification: specification,
                        itemType: itemType,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResourceSpecificationScreen(
                              specification: projectSpecs[index],
                              projectStatus: project.state,
                              itemType: itemType,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers (Ті самі, що і раніше) ---
  String? _getProjectDateInfo(Project project) {
    switch (project.state) {
      case ProjectState.planned:
        return 'Створено ${_formatDateTime(project.createdAt)}';
      case ProjectState.inProgress:
        return project.startDate != null
            ? 'Розпочато ${_formatDateTime(project.startDate)}'
            : 'Створено ${_formatDateTime(project.createdAt)}';
      case ProjectState.completed:
        return project.endDate != null
            ? 'Завершено ${_formatDateTime(project.endDate)}'
            : 'Завершено';
      case ProjectState.cancelled:
        return 'Скасовано';
    }
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog({
    required String title,
    required DateTime? initialDate,
    required double? initialIncome,
    required double? initialHours,
    required String currency,
    required Function(DateTime?, double?, double?) onSave,
  }) async {
    DateTime? selectedDate = initialDate;
    final incomeController = TextEditingController(
      text: initialIncome?.toString() ?? '',
    );
    final hoursController = TextEditingController(
      text: initialHours?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.dialogBackground,
              title: Text(title, style: TextStyle(color: AppColors.purple)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Вибір дати з можливістю очищення
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          labelStyle: TextStyle(color: AppColors.purple),
                          border: const OutlineInputBorder(),
                          // Якщо дата обрана, показуємо кнопку "Очистити", інакше іконку календаря
                          suffixIcon: selectedDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    // Очищаємо дату
                                    setState(() => selectedDate = null);
                                  },
                                )
                              : const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.purple,
                                ),
                        ),
                        child: Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!)!
                              : 'Not picked',
                          style: TextStyle(
                            color: selectedDate == null
                                ? AppColors.purple
                                : AppColors.pink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Введення доходу
                    TextField(
                      style: TextStyle(color: AppColors.purple),
                      controller: incomeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Revenue',
                        labelStyle: TextStyle(color: AppColors.purple),
                        border: const OutlineInputBorder(),
                        suffixText: currency,
                        suffixStyle: TextStyle(color: AppColors.purple),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Введення годин
                    TextField(
                      style: TextStyle(color: AppColors.purple),
                      controller: hoursController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Working hours',
                        labelStyle: TextStyle(color: AppColors.purple),
                        border: OutlineInputBorder(),
                        suffixStyle: TextStyle(color: AppColors.purple),
                        suffixText: 'h',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reject'),
                ),
                GradientButton(
                  label: 'Save',
                  width: 100,
                  onPressed: () {
                    final income = double.tryParse(incomeController.text);
                    final hours = double.tryParse(hoursController.text);
                    // Передаємо selectedDate (який може бути null)
                    onSave(selectedDate, income, hours);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String? _formatDateTime(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(ProjectState status) {
    switch (status) {
      case ProjectState.planned:
        return Colors.grey;
      case ProjectState.inProgress:
        return Colors.blue;
      case ProjectState.completed:
        return Colors.green;
      case ProjectState.cancelled:
        return Colors.red;
    }
  }

  void _startProject() {}

  void _finishProject() {}

  void _cancelProject() {}
}
