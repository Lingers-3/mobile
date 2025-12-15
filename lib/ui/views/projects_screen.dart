import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_floating_button.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/data/models/projects/project.dart';
import 'package:pocketeer_mobile/providers/project_provider.dart';
import 'package:pocketeer_mobile/ui/views/projects/project_details_screen.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final Set<int> _selectedProjectIds = {};

  bool get _isSelectionMode => _selectedProjectIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProjects = context.watch<ProjectProvider>().projects;

    // --- 1. ФІЛЬТРАЦІЯ ТА СОРТУВАННЯ ---

    // СЕКЦІЯ: В ПРОЦЕСІ
    final inProgressProjects = allProjects
        .where((p) => p.state == ProjectState.inProgress)
        .toList();

    inProgressProjects.sort((a, b) {
      // Визначаємо ефективний Deadline (пріоритет у фактичного, потім запланований)
      final dateA = a.actualDeadline ?? a.plannedDeadline;
      final dateB = b.actualDeadline ?? b.plannedDeadline;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // Без Deadlineу - вниз
      if (dateB == null) return -1;

      return dateA.compareTo(dateB); // Від найближчого до найдальшого
    });

    // СЕКЦІЯ: ПЛАНУВАННЯ
    final plannedProjects = allProjects
        .where((p) => p.state == ProjectState.planned)
        .toList();

    plannedProjects.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt); // Спочатку нові
    });

    // СЕКЦІЯ: ЗАВЕРШЕНІ (Completed + Cancelled)
    final completedProjects = allProjects
        .where(
          (p) =>
              p.state == ProjectState.completed ||
              p.state == ProjectState.cancelled,
        )
        .toList();

    completedProjects.sort((a, b) {
      // Для завершених беремо endDate, для скасованих - updatedAt (як дату скасування)
      final dateA = a.endDate ?? a.updatedAt;
      final dateB = b.endDate ?? b.updatedAt;
      return dateB.compareTo(dateA); // Спочатку нещодавно завершені
    });

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: AppColors.primaryBackground,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.purple),
                onPressed: _clearSelection,
              ),
              title: Text(
                'Selected: ${_selectedProjectIds.length}',
                style: const TextStyle(color: AppColors.purple),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteSelectedDialog(context),
                ),
              ],
            )
          : AppBar(
              centerTitle: true,
              backgroundColor: AppColors.primaryBackground,
              title: const Text(
                "Projects",
                style: TextStyle(color: AppColors.purple),
              ), // Або ваш заголовок
            ),
      backgroundColor: AppColors.primaryBackground,

      floatingActionButton: CustomFloatingButton(
        heroTag: 'projects_screen_fab',
        onPressed: () => _showCreateProjectDialog(context),
      ),
      body: allProjects.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                if (inProgressProjects.isNotEmpty) ...[
                  _buildSectionHeader('IN PROCESS', Colors.blue),
                  ...inProgressProjects.map(
                    (p) => _buildProjectCard(context, p),
                  ),
                  const SizedBox(height: 16),
                ],

                if (plannedProjects.isNotEmpty) ...[
                  _buildSectionHeader('DRAFT', Colors.grey),
                  ...plannedProjects.map((p) => _buildProjectCard(context, p)),
                  const SizedBox(height: 16),
                ],

                if (completedProjects.isNotEmpty) ...[
                  _buildSectionHeader('FINISHED', Colors.green),
                  ...completedProjects.map(
                    (p) => _buildProjectCard(context, p),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
          const Expanded(child: Divider(indent: 12)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    // Вибираємо, яку дату показувати на картці залежно від статусу
    String dateLabel = '';
    String dateValue = '';

    switch (project.state) {
      case ProjectState.inProgress:
        final deadline = project.actualDeadline ?? project.plannedDeadline;
        if (deadline != null) {
          dateLabel = 'Deadline:';
          dateValue = _formatDate(deadline);
        } else {
          dateLabel = 'Deadline:';
          dateValue = '-';
        }
        break;
      case ProjectState.planned:
        dateLabel = 'Created:';
        dateValue = _formatDate(project.createdAt);
        break;
      case ProjectState.completed:
        dateLabel = 'Completed:';
        dateValue = project.endDate != null
            ? _formatDate(project.endDate!)
            : '---';
        break;
      case ProjectState.cancelled:
        dateLabel = 'Canceled:';
        dateValue = _formatDate(project.updatedAt);
        break;
    }

    String timeText = '-';
    Color timeColor = Colors.grey.shade700;
    final plannedHours = project.plannedHours ?? 0;
    final actualHours = project.actualHours ?? 0;

    if (plannedHours != 0 && actualHours != 0) {
      final actual = actualHours
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.0$'), '');
      final planned = plannedHours
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.0$'), '');

      timeText = '$actual/$planned год';
    }

    String incomeText = '-';
    Color incomeColor = Colors.grey.shade700;
    final actualIncome = project.actualIncome;

    if (project.state == ProjectState.planned) {
      incomeText = project.plannedIncome != null
          ? '${project.plannedIncome!.toStringAsFixed(0)} ${project.currency}'
          : '-';
    } else if (actualIncome != null) {
      incomeText = '${actualIncome.toStringAsFixed(0)} ${project.currency}';
      if (actualIncome > 0) incomeColor = Colors.green[700]!;
    }

    final desc = project.description ?? '';

    final isSelected = _selectedProjectIds.contains(project.id);

    return Card(
      color: isSelected
          ? AppColors.purple.withValues(alpha: 0.1)
          : AppColors.primaryBackground,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(project.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(projectId: project.id),
              ),
            );
          }
        },
        onLongPress: () => _toggleSelection(project.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: AppColors.purple,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: timeColor),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: timeColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                desc.isNotEmpty ? desc : 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$dateLabel $dateValue',
                        style: TextStyle(
                          color: project.state != ProjectState.cancelled
                              ? Colors.grey.shade500
                              : Colors.red.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        incomeText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: incomeColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: incomeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_add, size: 64, color: AppColors.pink),
          SizedBox(height: 16),
          Text(
            'There are no projects yet\nCreate your first project!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.pink),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'New Project',
          style: TextStyle(color: AppColors.purple),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              labelText: 'Project name',

              autofocus: true,
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),

            style: OutlinedButton.styleFrom(
              fixedSize: Size(80, 50),

              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.purple),
            ),
          ),

          GradientButton(
            label: 'Create',
            width: 100,
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final newProject = await context
                    .read<ProjectProvider>()
                    .createProject(nameController.text.trim());
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProjectDetailsScreen(projectId: newProject.id),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedProjectIds.contains(id)) {
        _selectedProjectIds.remove(id);
      } else {
        _selectedProjectIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedProjectIds.clear();
    });
  }

  void _showDeleteSelectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'Delete Projects',
          style: TextStyle(color: AppColors.purple),
        ),
        content: Text(
          'Delete ${_selectedProjectIds.length} projects? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<ProjectProvider>();
              final idsToDelete = _selectedProjectIds.toList();

              Navigator.pop(ctx);

              for (final id in idsToDelete) {
                await provider.deleteProject(id);
              }

              _clearSelection();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
