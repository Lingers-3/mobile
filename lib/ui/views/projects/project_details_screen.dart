import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
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
      appBar: AppBar(
        title: Text(project.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
        heroTag: 'project_details_fab_${project.id}', // Унікальний тег
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
        label: const Text('Додати ресурс'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
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
                            project.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(project.status),
                          ),
                        ),
                        child: Text(
                          project.status.label,
                          style: TextStyle(
                            color: _getStatusColor(project.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (dateInfo != null)
                        Text(
                          dateInfo,
                          style: TextStyle(
                            color: Colors.grey.shade600,
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
                        () => _isDescriptionExpanded = !_isDescriptionExpanded,
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
                              color: Colors.black87,
                            ),
                          ),
                          if (!_isDescriptionExpanded && desc.length > 100)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Розгорнути...',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else
                    const Text(
                      "Немає опису",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // --- ДЗЕРКАЛЬНІ КОЛОНКИ ---
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('ЗАПЛАНОВАНО', Colors.grey),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Дедлайн',
                          value: _formatDate(project.plannedDeadline) ?? '—',
                        ),
                        _buildReadOnlyField(
                          label: 'Дохід',
                          value:
                              project.plannedIncome != null &&
                                  project.plannedIncome != 0.0
                              ? '${project.plannedIncome} ${project.currency}'
                              : '—',
                        ),
                        _buildReadOnlyField(
                          label: 'Час виконання',
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
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('ФАКТИЧНО', Colors.blue),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Дедлайн',
                          value: _formatDate(project.actualDeadline) ?? '—',
                          isBold: true,
                        ),
                        _buildReadOnlyField(
                          label: 'Дохід',
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
                          label: 'Час виконання',
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

            // --- РЕСУРСИ ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'РЕСУРСИ ПРОЕКТУ',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            if (projectSpecs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('Ресурси ще не додані')),
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
                          projectStatus: project.status,
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
    );
  }

  // --- Helpers (Ті самі, що і раніше) ---
  String? _getProjectDateInfo(Project project) {
    switch (project.status) {
      case ProjectStatus.planned:
        return 'Створено ${_formatDateTime(project.createdAt)}';
      case ProjectStatus.inProgress:
        return project.startDate != null
            ? 'Розпочато ${_formatDateTime(project.startDate)}'
            : 'Створено ${_formatDateTime(project.createdAt)}';
      case ProjectStatus.completed:
        return project.endDate != null
            ? 'Завершено ${_formatDateTime(project.endDate)}'
            : 'Завершено';
      case ProjectStatus.cancelled:
        return 'Скасовано';
    }
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.0,
      ),
    );
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

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String? _formatDateTime(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}
