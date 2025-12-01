import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/tags/tag_create_request.dart';
import 'package:pocketeer_mobile/data/models/tags/tag_update_request.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/gradient_button.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ManageTagsScreen extends StatefulWidget {
  const ManageTagsScreen({super.key});

  @override
  State<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends State<ManageTagsScreen> {
  final _text = TextEditingController();
  Color _selectedColor = AppColors.pink;
  bool _saving = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<TagProvider>();
      if (prov.tags.isEmpty && !prov.loading) {
        prov.loadTags();
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _hexFromColor(Color c) => c.value.toRadixString(16).substring(2);

  Future<void> _saveTag({
    required String name,
    required String hexColor,
    int? id,
  }) async {
    setState(() => _saving = true);
    bool success = false;

    if (id == null) {
      final created = await context.read<TagProvider>().createTag(
        TagCreateRequest(name: name, color: hexColor),
      );
      success = created != null;
    } else {
      final updated = await context.read<TagProvider>().updateTag(
        id,
        TagUpdateRequest(name: name, color: hexColor),
      );
      success = updated != null;
    }

    setState(() => _saving = false);
    if (success) {
      await context.read<TagProvider>().loadTags();
      _changed = true;
      if (mounted) Navigator.pop(context, true);
      _showSnack(id == null ? "Tag created" : "Tag updated");
    } else {
      _showSnack("Failed to save tag");
    }
  }

  Future<void> _deleteTag(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          "Delete tag",
          style: TextStyle(color: AppColors.purple),
        ),
        content: const Text(
          "Are you sure? This cannot be undone.",
          style: TextStyle(color: AppColors.pink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.cyan),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _saving = true);
    final ok = await context.read<TagProvider>().deleteTag(id);
    setState(() => _saving = false);

    if (ok) {
      await context.read<TagProvider>().loadTags();
      _changed = true;
      _showSnack("Tag deleted");
    } else {
      _showSnack("Failed to delete tag");
    }
  }

  void _openDialog({int? id, String? name, String? color}) {
    _text.text = name ?? "";
    Color tempColor = color != null
        ? Color(int.parse("0xff$color"))
        : _selectedColor;
    _selectedColor = tempColor;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.dialogBackground,
          title: Text(
            id == null ? "Create Tag" : "Edit Tag",
            style: const TextStyle(color: AppColors.purple),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _text,
                style: const TextStyle(color: AppColors.pink),
                decoration: const InputDecoration(
                  hintText: "Tag name",
                  hintStyle: TextStyle(color: AppColors.cyan),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    "Color:",
                    style: TextStyle(color: AppColors.purple),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final c = await _pickColor();
                      if (c != null) {
                        setDialogState(() => tempColor = c);
                        setState(() => _selectedColor = c);
                      }
                    },
                    child: CircleAvatar(backgroundColor: tempColor, radius: 16),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.cyan),
              ),
            ),
            SizedBox(
              width: 140,
              child: GradientButton(
                label: "Save",
                onPressed: _saving
                    ? null
                    : () {
                        final name = _text.text.trim();
                        if (name.isEmpty) {
                          _showSnack("Enter tag name");
                          return;
                        }
                        _saveTag(
                          id: id,
                          name: name,
                          hexColor: _hexFromColor(tempColor),
                        );
                      },
                loading: _saving,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TagProvider>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: AppColors.purple),
          backgroundColor: AppColors.primaryBackground,
          title: const Text(
            "Manage Tags",
            style: TextStyle(color: AppColors.purple),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.pink,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _openDialog(),
        ),
        body: RefreshIndicator(
          onRefresh: () => context.read<TagProvider>().loadTags(),
          color: AppColors.pink,
        child: prov.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.pink),
              )
            : prov.error != null
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      prov.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : prov.tags.isEmpty
            ? ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No tags yet. Create one with the + button.",
                      style: TextStyle(color: AppColors.cyan),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: prov.tags.length,
                itemBuilder: (_, i) {
                  final t = prov.tags[i];
                  return ListTile(
                      title: Text(
                        t.name,
                        style: const TextStyle(color: AppColors.pink),
                      ),
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor: t.color != null
                            ? Color(int.parse("0xff${t.color}"))
                            : AppColors.pink,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.pink),
                            onPressed: () => _openDialog(
                              id: t.id,
                              name: t.name,
                              color: t.color,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.cyan,
                            ),
                            onPressed: _saving ? null : () => _deleteTag(t.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<Color?> _pickColor() async {
    final start = _selectedColor;
    int r = start.red;
    int g = start.green;
    int b = start.blue;

    final c = await showDialog<Color>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final current = Color.fromARGB(255, r, g, b);
          final hex = current.value
              .toRadixString(16)
              .substring(2)
              .toUpperCase();
          return AlertDialog(
            backgroundColor: AppColors.dialogBackground,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pick color",
                  style: TextStyle(color: AppColors.purple),
                ),
                Text("#$hex", style: const TextStyle(color: AppColors.pink)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(backgroundColor: current, radius: 18),
                const SizedBox(height: 16),
                _colorSlider(
                  label: "R",
                  value: r.toDouble(),
                  onChanged: (v) => setDialog(() => r = v.toInt()),
                  activeColor: Colors.red,
                ),
                _colorSlider(
                  label: "G",
                  value: g.toDouble(),
                  onChanged: (v) => setDialog(() => g = v.toInt()),
                  activeColor: Colors.green,
                ),
                _colorSlider(
                  label: "B",
                  value: b.toDouble(),
                  onChanged: (v) => setDialog(() => b = v.toInt()),
                  activeColor: Colors.blue,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.cyan),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, current),
                child: const Text(
                  "Save",
                  style: TextStyle(color: AppColors.pink),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (c != null) {
      setState(() => _selectedColor = c);
    }
    return c;
  }

  Widget _colorSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color activeColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(label, style: const TextStyle(color: AppColors.pink)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: activeColor,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
