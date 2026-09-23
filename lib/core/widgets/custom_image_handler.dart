import 'package:flutter/material.dart';
import 'package:food/core/constants/app_colors.dart';

class CustomImageHandler extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;
  final double iconSize;

  const CustomImageHandler({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderIcon = Icons.fastfood,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (imageUrl.startsWith('http')) {
      // It's a network image
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(icon: Icons.broken_image);
        },
      );
    } else {
      // It's a local asset
      final cleanPath = imageUrl.trim();
      return Image.asset(
        cleanPath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("❌ ERROR LOADING ASSET: '$cleanPath'");
          debugPrint("   Reason: $error");
          return _buildPlaceholder(icon: Icons.image_not_supported);
        },
      );
    }
  }

  Widget _buildPlaceholder({IconData? icon}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.grayLight,
      child: Center(
        child: Icon(
          icon ?? placeholderIcon,
          color: AppColors.primary,
          size: iconSize,
        ),
      ),
    );
  }
}
