import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';
import 'package:pocketeer_mobile/ui/views/inventory/tags/manage_tags_screen.dart';
import 'package:provider/provider.dart';

import 'tag_chip.dart';

class TagSelector extends StatefulWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  const TagSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<int> _currentSelection = [];

  @override
  void initState() {
    super.initState();
    _currentSelection = [...widget.selected];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<TagProvider>();
      if (prov.tags.isEmpty && !prov.loading) {
        await prov.loadTags();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TagSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.selected, widget.selected)) {
      _currentSelection = [...widget.selected];
    }
  }

  void _toggle(int id) {
    setState(() {
      if (_currentSelection.contains(id)) {
        _currentSelection.remove(id);
      } else {
        _currentSelection.add(id);
      }
    });
    widget.onChanged(List<int>.from(_currentSelection));
  }

  Future<void> _openSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.dialogBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String search = "";
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final prov = ctx.watch<TagProvider>();
            final filtered = prov.tags
                .where(
                  (t) => t.name.toLowerCase().contains(search.toLowerCase()),
                )
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search tags...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(.5)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.purple,
                      ),
                      filled: true,
                      fillColor: AppColors.primaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: AppColors.pink),
                    onChanged: (v) => setSheetState(() => search = v),
                  ),
                  const SizedBox(height: 12),
                  if (prov.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: AppColors.pink),
                    )
                  else if (prov.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        prov.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  else if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No tags found",
                        style: TextStyle(color: AppColors.cyan),
                      ),
                    )
                  else
                    SizedBox(
                      height: 320,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final tag = filtered[i];
                          final isSelected = _currentSelection.contains(tag.id);
                          final tagColor = tag.color != null
                              ? Color(int.parse("0xff${tag.color}"))
                              : AppColors.pink;
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) {
                              _toggle(tag.id);
                              setSheetState(() {});
                            },
                            title: Text(
                              tag.name,
                              style: TextStyle(color: tagColor),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: tagColor,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Done",
                      style: TextStyle(color: AppColors.pink),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagProv = context.watch<TagProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tags",
              style: TextStyle(color: AppColors.purple, fontSize: 16),
            ),
            TextButton(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageTagsScreen()),
                );
                if (!mounted) return;
                if (changed == true) {
                  await context.read<TagProvider>().loadTags();
                }
              },
              child: const Text(
                "Manage",
                style: TextStyle(color: AppColors.pink),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withOpacity(.6)),
            ),
            child: tagProv.loading
                ? const Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: AppColors.pink),
                    ),
                  )
                : tagProv.error != null
                ? Text(
                    tagProv.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  )
                : (_currentSelection.isEmpty)
                ? Text(
                    "Select tags",
                    style: TextStyle(color: Colors.white.withOpacity(.6)),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _currentSelection.map((id) {
                      final tag = tagProv.getById(id);
                      if (tag == null) return const SizedBox();
                      return TagChip(
                        label: tag.name,
                        color: tag.color,
                        selected: true,
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
