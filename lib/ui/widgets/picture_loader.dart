import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/picture_meta.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/providers/picture_provider.dart';
import 'package:pocketeer_mobile/ui/widgets/secure_image.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class PictureLoader extends StatefulWidget {
  final int pictureId;
  final double size;
  final double borderRadius;
  final Widget? placeholderIcon;

  const PictureLoader({
    super.key,
    required this.pictureId,
    this.size = 50,
    this.borderRadius = 8,
    this.placeholderIcon,
  });

  @override
  State<PictureLoader> createState() => _PictureLoaderState();
}

class _PictureLoaderState extends State<PictureLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PictureProvider>().fetchPictureMeta(widget.pictureId);
    });
  }

  @override
  void didUpdateWidget(covariant PictureLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pictureId != widget.pictureId) {
      context.read<PictureProvider>().fetchPictureMeta(widget.pictureId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = context.select<PictureProvider, PictureMeta?>(
      (provider) => provider.getMetaById(widget.pictureId),
    );

    final defaultIcon =
        widget.placeholderIcon ??
        const Icon(Icons.image, color: AppColors.purple);

    if (meta == null) {
      return _buildContainer(
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.purple,
          ),
        ),
      );
    }

    return SecureImage(
      pictureHash: meta.hash,
      width: widget.size,
      height: widget.size,
      borderRadius: widget.borderRadius,
      placeholderIcon: defaultIcon,
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(child: child),
    );
  }
}
