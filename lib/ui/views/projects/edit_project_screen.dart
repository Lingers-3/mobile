import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/projects/project_state.dart';
import 'package:pocketeer_mobile/data/models/projects/project_update_request.dart';
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

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final updatedProject = widget.project.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
      context.read<ProjectProvider>().updateProject(updatedProject);
      Navigator.pop(context);
    }
  }
}
