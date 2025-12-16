import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/item_types/item_type.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_date_input.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/ui/views/projects/resource_specification_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects/select_resource_item_type_screen.dart';
import 'package:pocketeer_mobile/ui/views/projects/edit_project_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/resource_specification/resource_specification_card.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProject(
        widget.projectId,
        force: true,
      );
      context.read<ItemTypeProvider>().loadItemTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = context.select<ProjectProvider, Project?>(
      (pp) => pp.getById(widget.projectId),
    );

    if (project == null) {
      // TODO(saloway): make it more clear, return on the projects screen, idk
      return const Center(child: Text("The project is null"));
    }

    final projectSpecs = project.specifications ?? [];

    final relevantItemTypes = context.select<ItemTypeProvider, List<ItemType>>(
      (itp) => itp.itemTypes
          .where((it) => projectSpecs.any((s) => s.itemTypeId == it.id))
          .toList(),
    );

    final itemTypesById = {for (var it in relevantItemTypes) it.id: it};

    final dateInfo = _getProjectDateInfo(project);

    final desc = project.description;

    return Scaffold(
      // --- NAV HEADER ---
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.purple),
        title: Text(project.name, style: TextStyle(color: AppColors.purple)),
        centerTitle: true,
        actions: [
          // --- EDIT PROJECT ---
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
      // --- ADD RESOURCE BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'project_details_fab_${project.id}',
        backgroundColor: AppColors.pink,
        onPressed: () {
          final usedTypeIds = projectSpecs.map((s) => s.itemTypeId).toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectResourceSpecificationScreen(
                excludedItemTypeIds: usedTypeIds,
                projectId: project.id,
              ),
            ),
          );
        },
        label: const Text(
          'Add resource',
          style: TextStyle(color: AppColors.primaryBackground),
        ),
        icon: const Icon(Icons.add, color: AppColors.primaryBackground),
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
                          // -- PROJECT STATE CHIP ---
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
                          // -- PROJECT DATE INFO ---
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

                      // --- DESCRIPTION ---
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

                // --- PLAN / ACTUAL COLUMNS ---
                Container(
                  color: AppColors.primaryBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PLAN COLUMN ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // --- HEADER ---
                                Text(
                                  'PLANNED',
                                  style: TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),

                                // --- EDIT BUTTON ---
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: project.state == ProjectState.planned
                                        ? AppColors.purple
                                        : AppColors.purple.withValues(
                                            alpha: 0.5,
                                          ),
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
                                            initialHours:
                                                project.plannedWorkTime,
                                            currency: project.currency,
                                            onSave: (date, income, hours) {
                                              final projectProvider = context
                                                  .read<ProjectProvider>();
                                              projectProvider.updateProjectPlan(
                                                project.id,
                                                date,
                                                income,
                                                hours,
                                              );
                                            },
                                          );
                                        },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // --- DEADLINE FIELD ---
                            _buildReadOnlyField(
                              label: 'Deadline',
                              value:
                                  _formatDate(project.plannedDeadline) ?? '—',
                            ),

                            // --- REVENUE FIELD ---
                            _buildReadOnlyField(
                              label: 'Revenue',
                              value:
                                  project.plannedIncome != null &&
                                      project.plannedIncome != 0.0
                                  ? '${project.plannedIncome} ${project.currency}'
                                  : '—',
                            ),

                            // --- WORKING HOURS FIELD ---
                            _buildReadOnlyField(
                              label: 'Completion time',
                              value:
                                  project.plannedWorkTime != null &&
                                      project.plannedWorkTime != 0.0
                                  ? '${project.plannedWorkTime} h'
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

                      // --- ACTUAL COLUMN ---
                      Expanded(
                        child: Opacity(
                          opacity: project.state == ProjectState.planned
                              ? 0.5
                              : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // --- HEADER ---
                                  Text(
                                    'ACTUAL',
                                    style: TextStyle(
                                      color: AppColors.pink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                    ),
                                  ),

                                  // --- EDIT BUTTON ---
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color:
                                          project.state != ProjectState.planned
                                          ? AppColors.purple
                                          : AppColors.purple.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                    onPressed:
                                        project.state != ProjectState.inProgress
                                        ? null
                                        : () {
                                            _showEditDialog(
                                              title: 'Edit in Fact',
                                              initialDate:
                                                  project.actualDeadline,
                                              initialIncome:
                                                  project.actualRevenue,
                                              initialHours:
                                                  project.actualWorkTime,
                                              currency: project.currency,
                                              onSave: (date, income, hours) {
                                                context
                                                    .read<ProjectProvider>()
                                                    .updateProjectActual(
                                                      project.id,
                                                      date,
                                                      income,
                                                      hours,
                                                    );
                                              },
                                            );
                                          },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // --- DEADLINE FIELD ---
                              _buildReadOnlyField(
                                label: 'Deadline',
                                value:
                                    _formatDate(project.actualDeadline) ?? '—',
                                isBold: true,
                              ),

                              // --- REVENUE FIELD ---
                              _buildReadOnlyField(
                                label: 'Revenue',
                                value:
                                    project.actualRevenue != null &&
                                        project.actualRevenue != 0
                                    ? '${project.actualRevenue} ${project.currency}'
                                    : '—',
                                valueColor: (project.actualRevenue ?? 0) > 0
                                    ? Colors.green
                                    : null,
                              ),

                              // --- WORKING HOURS FIELD ---
                              _buildReadOnlyField(
                                label: 'Completion time',
                                value:
                                    project.actualWorkTime != null &&
                                        project.actualWorkTime != 0.0
                                    ? '${project.actualWorkTime} h'
                                    : '—',
                                valueColor:
                                    (project.plannedWorkTime != null &&
                                        (project.actualWorkTime ?? 0) >
                                            (project.plannedWorkTime ?? 0))
                                    ? Colors.red
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- PROJECT STATE ACTIONS ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // --- START BUTTON ---
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
                      // --- FINISH BUTTON ---
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
                          'Finish',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                      // --- CANCEL BUTTON ---
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
                          'Cancel',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- RESOURCES ---
                // --- SECTION HEADER ---
                const Divider(height: 1),
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

                // --- LIST ---
                if (projectSpecs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Resources not added yet',
                        style: TextStyle(
                          color: AppColors.purple,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectSpecs.length,
                    itemBuilder: (context, index) {
                      final specification = projectSpecs[index];
                      final itemType = itemTypesById[specification.itemTypeId];
                      if (itemType == null) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      return ResourceSpecificationCard(
                        key: ValueKey(specification.id),
                        itemType: itemType,
                        specification: specification,
                        onTap: project.state != ProjectState.planned
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResourceSpecificationScreen(
                                    projectId: project.id,
                                    specificationId: projectSpecs[index].id,
                                  ),
                                ),
                              )
                            : null,
                        onEdit: project.state != ProjectState.planned
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResourceSpecificationScreen(
                                    projectId: project.id,
                                    specificationId: projectSpecs[index].id,
                                  ),
                                ),
                              )
                            : null,
                        onDelete: () async {
                          try {
                            final provider = context.read<ProjectProvider>();

                            if (project.state != ProjectState.planned) {
                              await provider.removeResourceSpecification(
                                project.id,
                                projectSpecs[index].id,
                              );
                            } else {
                              await provider.unplanResource(
                                project.id,
                                projectSpecs[index].id,
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete failed')),
                            );
                          }
                        },
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

  // --- Helpers ---
  String _getProjectDateInfo(Project project) {
    switch (project.state) {
      case ProjectState.planned:
        return 'Created at ${_formatDateTime(project.createdAt)}';
      case ProjectState.inProgress:
        return project.startDate != null
            ? 'Started at ${_formatDateTime(project.startDate)}'
            : 'Created at ${_formatDateTime(project.createdAt)}';
      case ProjectState.completed:
        return project.endDate != null
            ? 'Finished at ${_formatDateTime(project.endDate)}'
            : 'Finished';
      case ProjectState.cancelled:
        return project.endDate != null
            ? 'Canceled at ${_formatDateTime(project.endDate)}'
            : 'Canceled';
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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.purple),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.pink,
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
    required int? initialHours,
    required String currency,
    required Function(DateTime?, double?, int?) onSave,
  }) async {
    DateTime? selectedDate = initialDate;
    final revenueController = TextEditingController(
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
                    // --- DATE FIELD ---
                    CustomDateInput(
                      selectedDate: selectedDate,
                      label: 'Deadline',
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                    ),

                    // --- REVENUE FIELD ---
                    TextField(
                      style: TextStyle(color: AppColors.purple),
                      controller: revenueController,
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

                    // --- WORKING HOURS FIELD ---
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
                // --- CANCEL BUTTON ---
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),

                // --- SAVE BUTTON ---
                GradientButton(
                  label: 'Save',
                  width: 100,
                  onPressed: () {
                    final income = double.tryParse(revenueController.text);
                    final hours = int.tryParse(hoursController.text);
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
        return AppColors.purple;
      case ProjectState.inProgress:
        return AppColors.cyan;
      case ProjectState.completed:
        return AppColors.pink;
      case ProjectState.cancelled:
        return Colors.red;
    }
  }
}
