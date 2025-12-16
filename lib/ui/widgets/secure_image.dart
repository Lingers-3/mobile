import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/data/services/auth_service.dart';
import 'package:pocketeer_mobile/theme/app_theme.dart';

class SecureImage extends StatelessWidget {
  final String pictureHash;
  final double width;
  final double height;
  final double borderRadius;
  final Widget placeholderIcon;

  const SecureImage({
    super.key,
    required this.pictureHash,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.placeholderIcon = const Icon(Icons.image, color: AppColors.purple),
  });

  @override
  Widget build(BuildContext context) {
    if (pictureHash.isEmpty) {
      return _buildContainer(child: placeholderIcon);
    }

    final imageUrl = "${AppConstants.baseUrl}/pictures/$pictureHash";

    String token = AuthService().ensureToken();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        httpHeaders: {'Authorization': 'Bearer $token'},
        placeholder: (context, url) => _buildContainer(
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.purple,
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            _buildContainer(child: placeholderIcon),
      ),
    );
  }

  // Допоміжний контейнер для фону
  Widget _buildContainer({required Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(child: child),
    );
  }
}
