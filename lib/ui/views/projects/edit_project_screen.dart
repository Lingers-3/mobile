import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
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

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.project;

    _nameController = TextEditingController(text: p.name);
    _descController = TextEditingController(text: p.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        iconTheme: IconThemeData(color: AppColors.purple),
        title: const Text(
          'Project editing',
          style: TextStyle(color: AppColors.purple),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProject),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Main information'),
            CustomTextField(
              controller: _nameController,
              labelText: 'Project name',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descController,
              labelText: 'Description',
              maxLines: 3,
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
              color: isActive ? AppColors.pink : AppColors.purple,
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

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final id = widget.project.id;
      final name = _nameController.text.trim();
      final description = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim();
      context.read<ProjectProvider>().updateProjectInfo(id, name, description);
      Navigator.pop(context);
    }
  }
}
